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

