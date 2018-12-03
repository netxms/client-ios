//
//  LoginViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 21/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{
   
   @IBOutlet weak var apiUrl: UITextField!
   @IBOutlet weak var login: UITextField!
   @IBOutlet weak var password: UITextField!
   @IBOutlet weak var underlineURL: UIView!
   @IBOutlet weak var underlinePassword: UIView!
   @IBOutlet weak var underlineUsername: UIView!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      loadCredentialsFromKeyChain()
   }
   
   override func didReceiveMemoryWarning()
   {
      if apiUrl.text?.isEmpty == false
      {
         underlineURL.backgroundColor = UIColor.darkGray
      }
      if login.text?.isEmpty == false
      {
         underlineUsername.backgroundColor = UIColor.darkGray
      }
      if password.text?.isEmpty == false
      {
         underlinePassword.backgroundColor = UIColor.darkGray
      }
      
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func onLoginSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData
      {
         DispatchQueue.main.async
            {
               Connection.sharedInstance?.session = Session(json: jsonData)
               Connection.sharedInstance?.getAllObjects()
               Connection.sharedInstance?.getRootObjects()
               Connection.sharedInstance?.getAllAlarms()
               Connection.sharedInstance?.getPredefinedGraphs()
               Connection.sharedInstance?.startNotificationHandler()
               self.storeCredentialsInKeyChain()
               let mainNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
               self.present(mainNavigationController, animated: true, completion: nil)
         }
      }
   }
   
   @IBAction func loginButtonPressed()
   {
      if !(apiUrl.text?.isEmpty)! && !(login.text?.isEmpty)!
      {
         Connection.sharedInstance = Connection(login: login.text!, password: password.text ?? "", apiUrl: apiUrl.text!)
         Connection.sharedInstance?.login(onSuccess: onLoginSuccess)
      }
   }
   
   func storeCredentialsInKeyChain()
   {
      if !(apiUrl.text?.isEmpty)! && !(login.text?.isEmpty)!
      {
         KeychainWrapper.standard.set(apiUrl.text!, forKey: "NetXMSApiUrl")
         KeychainWrapper.standard.set(login.text!, forKey: "NetXMSLogin")
         KeychainWrapper.standard.set(password.text ?? "", forKey: "NetXMSPassword")
      }
   }
   
   func loadCredentialsFromKeyChain()
   {
      if let retreivedApiUrl = KeychainWrapper.standard.string(forKey: "NetXMSApiUrl"),
         let retreivedLogin = KeychainWrapper.standard.string(forKey: "NetXMSLogin"),
         let retreivedPassword = KeychainWrapper.standard.string(forKey: "NetXMSPassword")
      {
         self.apiUrl.insertText(retreivedApiUrl)
         self.login.insertText(retreivedLogin)
         self.password.insertText(retreivedPassword)
         
         loginButtonPressed()
      }
   }
   
   @IBAction func onUrlEdit(_ sender: Any)
   {
      self.underlineURL.backgroundColor = UIColor.darkGray
   }
   
   @IBAction func onUrlstopEdit(_ sender: Any)
   {
      if self.apiUrl.text?.isEmpty == true
      {
         self.underlineURL.backgroundColor = UIColor.lightGray
      }
   }
   
   @IBAction func onUsernameEdit(_ sender: Any)
   {
      self.underlineUsername.backgroundColor = UIColor.darkGray
   }
   
   @IBAction func onUsernameStopEdit(_ sender: Any)
   {
      if self.login.text?.isEmpty == true
      {
         self.underlineUsername.backgroundColor = UIColor.lightGray
      }
   }
   
   @IBAction func onPasswordEdit(_ sender: Any)
   {
      self.underlinePassword.backgroundColor = UIColor.darkGray
   }
   
   @IBAction func onPasswordStopEdit(_ sender: Any)
   {
      if self.password.text?.isEmpty == true
      {
         self.underlinePassword.backgroundColor = UIColor.lightGray
      }
   }
}
