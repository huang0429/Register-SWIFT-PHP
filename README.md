# SWIFT-PHP-MYSQL註冊使用者

## 系統
macOS Monterey 12.6  
XAMPP 8.1.6  
XCode 14  

## 建立資料庫結構

![](https://i.imgur.com/E70Rhhq.jpg)

## Web Service - PHP

需要建立2個資料夾跟檔案

include/  
    Constants.php  
    DbConnect.php  
    DbOperation.php  
v1/  
    register.php  

![](https://i.imgur.com/DLppDq8.jpg)

## 程式碼

以下會有四個PHP的程式碼

**Constants.php**的程式碼
```php=
<?php
define('DB_USERNAME', 'Demo');
define('DB_PASSWORD', '0000');
define('DB_HOST', 'localhost');
define('DB_NAME', 'Demo');

define('USER_CREATED', 0);
define('USER_ALREADY_EXIST', 1);
define('USER_NOT_CREATED', 2);
?>
```

**DbConnect.php**的程式碼

```php=
<?php

class DbConnect
{
    private $conn;

    function __construct()
    {
    }

    /**
     * Establishing database connection
     * @return database connection handler
     */
    function connect()
    {
        require_once 'Constants.php';

        // Connecting to mysql database
        $this->conn = new mysqli(DB_HOST, DB_USERNAME, DB_PASSWORD, DB_NAME);

        // Check for database connection error
        if (mysqli_connect_errno()) {
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
        }

        // returing connection resource
        return $this->conn;
    }
}

?>
```

**DbOperation.php**的程式碼

```php=
<?php

class DbOperation
{
    private $conn;

    //Constructor
    function __construct()
    {
        require_once dirname(__FILE__) . '/Constants.php';
        require_once dirname(__FILE__) . '/DbConnect.php';
        // opening db connection
        $db = new DbConnect();
        $this->conn = $db->connect();
    }
    
    //Function to create a new user 註冊
    public function createUser($username, $pass, $email, $name, $phone)
    {
        if (!$this->isUserExist($username, $email, $phone)) {
            $password = md5($pass);
            $stmt = $this->conn->prepare("INSERT INTO users (username, password, email, name, phone) VALUES (?, ?, ?, ?, ?)");
            $stmt->bind_param("sssss", $username, $password, $email, $name, $phone);
            if ($stmt->execute()) {
                return USER_CREATED;
            } else {
                return USER_NOT_CREATED;
            }
        } else {
            return USER_ALREADY_EXIST;
        }
    }
    private function isUserExist($username, $email, $phone)
    {
        $stmt = $this->conn->prepare("SELECT id FROM users WHERE username = ? OR email = ? OR phone = ?");
        $stmt->bind_param("sss", $username, $email, $phone);
        $stmt->execute();
        $stmt->store_result();
        return $stmt->num_rows > 0;
    }
}

?>
```

**register.php**的程式碼

```php=

<?php

//importing required script
require_once '../include/DbOperation.php';

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!verifyRequiredParams(array('username', 'password', 'email', 'name', 'phone'))) {
        //getting values
        $username = $_POST['username'];
        $password = $_POST['password'];
        $email = $_POST['email'];
        $name = $_POST['name'];
        $phone = $_POST['phone'];

        //creating db operation object
        $db = new DbOperation();

        //adding user to database
        $result = $db->createUser($username, $password, $email, $name, $phone);

        //making the response accordingly
        if ($result == USER_CREATED) {
            $response['error'] = false;
            $response['message'] = 'User created successfully';
        } elseif ($result == USER_ALREADY_EXIST) {
            $response['error'] = true;
            $response['message'] = 'User already exist';
        } elseif ($result == USER_NOT_CREATED) {
            $response['error'] = true;
            $response['message'] = 'Some error occurred';
        }
    } else {
        $response['error'] = true;
        $response['message'] = 'Required parameters are missing';
    }
} else {
    $response['error'] = true;
    $response['message'] = 'Invalid request';
}

//function to validate the required parameter in request
function verifyRequiredParams($required_fields)
{

    //Getting the request parameters
    $request_params = $_REQUEST;

    //Looping through all the parameters
    foreach ($required_fields as $field) {
        //if any requred parameter is missing
        if (!isset($request_params[$field]) || strlen(trim($request_params[$field])) <= 0) {

            //returning true;
            return true;
        }
    }
    return false;
}

echo json_encode($response);

?>
```

## 測試是否能連線 - POSTMAN

![](https://i.imgur.com/yp1nSps.jpg)

## 新增 XCode 專案

新增完後先關閉 XCode  
因為要安裝 Alamofire  
要安裝 Alamofire前  
要先安裝 CocoaPods  

## 安裝 CocoaPods

打開終端並執行以下命令  
這可能需要一些時間
```bash=
sudo gem install cocoapods --pre
```

## 安裝Alamofire

用終端機打開 XCode 的專案

![](https://i.imgur.com/bZvKltt.jpg)

輸入下列指令：
```bash=
pod init
```

資料夾會多出幾個檔案

![](https://i.imgur.com/YHyB2X4.jpg)

打開 Podfile 

加入 `pod 'Alamofire', '~> 4.3'`

```swift=
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target '1011LoginDemo' do
 use_frameworks!
 pod 'Alamofire', '~> 4.3'
end
```

![](https://i.imgur.com/fXGIyUu.jpg)

儲存後關閉

回終端機

輸入指令：
```bash=
pod install
```

完成後打開副檔名為 .xcworkspace 的檔案

## Xcode 新增接口

先拉出元件

![](https://i.imgur.com/mTsZk4O.jpg)


然後將元件跟程式碼做繫結  

下列是程式碼：  

```swift=

//
//  ViewController.swift
//  LoginDemo
//
//  Created by 黃筱珮 on 2022/10/8.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    //web服務器的網址
    var URL_USER_REGISTER = "http://localhost:8080/LoginDemo/v1%20/register.php"
    
    //元件繫結
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 處理所有可以重新創建的資源。
    }
    
    //註冊執行內容
    @IBAction func buttonRegister(_ sender: Any) {
        
        //發布請求創建參數
        let parameters: Parameters=[
            "username":textFieldUsername.text!,
            "password":textFieldPassword.text!,
            "name":textFieldName.text!,
            "email":textFieldEmail.text!,
            "phone":textFieldPhone.text!
        ]
        
        //發送http post請求
        Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
        {
            response in
            //printing response
            print(response)
            
            //從服務器獲取 json 值
            if let result = response.result.value {
                
                //將其轉換為 NSDictionary
                let jsonData = result as! NSDictionary
                
                //在標籤中顯示消息
                self.labelMessage.text = jsonData.value(forKey: "message") as! String?
            }
        }
        
    }
    
    
}



```

## APP 測試

如果 postman 有測試成功，這裡應該是沒問題