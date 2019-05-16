//
//  LoginViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 21/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController
{
   @IBOutlet weak var apiUrl: UITextField!
   @IBOutlet weak var login: UITextField!
   @IBOutlet weak var password: UITextField!
   @IBOutlet weak var underlineURL: UIView!
   @IBOutlet weak var underlinePassword: UIView!
   @IBOutlet weak var underlineUsername: UIView!
   @IBOutlet weak var loginButton: UIButton!
   @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      
      loadCredentialsFromKeyChain()
      
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
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
      tap.cancelsTouchesInView = false
      self.view.addGestureRecognizer(tap)
   }
   
   override func viewWillAppear(_ animated: Bool)
   {
      self.navigationController?.setNavigationBarHidden(true, animated: false)
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      self.navigationController?.setNavigationBarHidden(false, animated: false)
   }
   
   @objc func dismissKeyboard()
   {
      self.view.endEditing(true)
   }
   
   @objc func keyboardWillChange(notification: Notification)
   {
      if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
      {
         let keyboardRectangle = keyboardFrame.cgRectValue
         if notification.name == NSNotification.Name.UIKeyboardWillShow
         {
            self.keyboardViewHeight.constant = keyboardRectangle.height
         }
         else
         {
            self.keyboardViewHeight.constant = 0
         }
         self.view.updateConstraints()
      }
   }
   
   func onLoginSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData
      {
         DispatchQueue.main.async
         {
            Connection.sharedInstance?.session = Session(json: jsonData)
            Connection.sharedInstance?.getAllObjects()
            Connection.sharedInstance?.getAllAlarms()
            Connection.sharedInstance?.getPredefinedGraphs()
            Connection.sharedInstance?.startNotificationHandler()
            self.storeCredentialsInKeyChain()
            let mainNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
            self.present(mainNavigationController, animated: true, completion: nil)
         }
      }
   }
   
   /**
    * Handler for failed login to NetXMS WebAPI
    */
   func onLoginFailure(data: Any?)
   {
      if let response = data as? HTTPURLResponse
      {
         DispatchQueue.main.async
         {
            self.createErrorDialog(message: "Login failed with the code: \(response.statusCode)")
         }
      }
      else if let response = data as? String
      {
         DispatchQueue.main.async
         {
            self.createErrorDialog(message: response)
         }
      }
   }
   
   func createErrorDialog(message: String)
   {
      //Creating UIAlertController and
      //Setting title and message for the alert dialog
      let alertController = UIAlertController(title: "Login failed", message: message, preferredStyle: .alert)

      //the cancel action doing nothing
      let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (_) in }
      alertController.addAction(cancelAction)

      //finally presenting the dialog box
      self.present(alertController, animated: true, completion: nil)
   }
   
   override func viewWillLayoutSubviews()
   {
      print("Will Layout: \(loginButton.layer.bounds)")
      MainNavigationController.setButtonStyle(button: loginButton)
   }
   
   override func viewDidLayoutSubviews()
   {
      //print("Did Layout: \(loginButton.layer.bounds)")
      MainNavigationController.setButtonStyle(button: loginButton)
   }
   
   override func viewDidAppear(_ animated: Bool)
   {
      super.viewDidAppear(animated)
   }
   
   @IBAction func loginButtonPressed()
   {
      if !(apiUrl.text?.isEmpty)! && !(login.text?.isEmpty)!
      {
         Connection.sharedInstance = Connection(login: login.text!, password: password.text ?? "", apiUrl: apiUrl.text!)
         Connection.sharedInstance?.loginView = self
         Connection.sharedInstance?.login(onSuccess: onLoginSuccess, onFailure: onLoginFailure)
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
