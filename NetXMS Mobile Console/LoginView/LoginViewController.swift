//
//  LoginViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 21/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
   @IBOutlet var apiUrl: UITextField!
   @IBOutlet weak var login: UITextField!
   @IBOutlet weak var password: UITextField!
   @IBOutlet weak var underlineURL: UIView!
   @IBOutlet weak var underlinePassword: UIView!
   @IBOutlet weak var underlineUsername: UIView!
   @IBOutlet weak var loginButton: UIButton!
   @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
   @IBOutlet var historyTable: UITableView!
   @IBOutlet var historyTableHeight: NSLayoutConstraint!
   @IBOutlet var errorLabel: UILabel!
   var credentialHistory: [String]!
   var filteredCredentialHistory: [String]!
   var alert: UIAlertController!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      self.apiUrl.addTarget(self, action: #selector(apiUrlIsEdited), for: .editingChanged)
      
      loadCredentialsFromKeyChain()
      
      self.apiUrl.delegate = self
      self.login.delegate = self
      self.password.delegate = self
      
      self.historyTable.delegate = self
      self.historyTable.dataSource = self
      
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
   
   override func viewWillLayoutSubviews()
   {
      MainNavigationController.setButtonStyle(button: loginButton)
   }
   
   override func viewDidLayoutSubviews()
   {
      MainNavigationController.setButtonStyle(button: loginButton)
   }
   
   override func viewDidAppear(_ animated: Bool)
   {
      super.viewDidAppear(animated)
   }
   
   func reload()
   {
      if (credentialHistory.count > 0)
      {
         if let filterString = self.apiUrl?.text,
            !filterString.isEmpty
         {
            filteredCredentialHistory = credentialHistory.filter { $0.localizedCaseInsensitiveContains(filterString) }
         }
         else
         {
            filteredCredentialHistory = credentialHistory
         }
         let credentialCount = CGFloat(filteredCredentialHistory.count)
         historyTableHeight.constant = credentialCount < 9 ? credentialCount * historyTable.rowHeight : 480
         self.historyTable.reloadData()
         self.view.updateConstraints()
      }
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return filteredCredentialHistory.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      if let cell = tableView.dequeueReusableCell(withIdentifier: "CredentialHistoryCell", for: indexPath) as? CredentialHistoryCell
      {
         if let credentials = filteredCredentialHistory[indexPath.row].components(separatedBy: "@") as [String]?,
            credentials.count == 2
         {
            cell.fillCell(url: credentials[1], name: credentials[0])

            return cell
         }
      }
      return UITableViewCell()
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      self.historyTable.deselectRow(at: indexPath, animated: false)
      if let cell = tableView.cellForRow(at: indexPath) as? CredentialHistoryCell
      {
         if let url = cell.url.text,
            let login = cell.name.text
         {
            self.apiUrl.text = url
            self.login.text = login
            if let pass = KeychainWrapper.standard.string(forKey: login)
            {
               self.password.text = pass
               self.underlinePassword.backgroundColor = UIColor.darkGray
            }
            else
            {
               self.password.text = ""
            }
            self.underlineURL.backgroundColor = UIColor.darkGray
            self.underlineUsername.backgroundColor = UIColor.darkGray
         }
      }
   }
   
   func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
   {
      let delete = UITableViewRowAction(style: .default, title: "Delete") { (rowAction, indexPath) in
         self.clearCredentialEntry(entry: self.filteredCredentialHistory[indexPath.row])
      }
      
      return [delete]
   }
   
   @IBAction func onUrlEdit(_ sender: Any)
   {
      reload()
      self.underlineURL.backgroundColor = UIColor.darkGray
   }
   
   @IBAction func onUrlstopEdit(_ sender: Any)
   {
      self.historyTableHeight.constant = 0
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
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool
   {
      loginButtonPressed()
      return true
   }
   
   func textFieldShouldClear(_ textField: UITextField) -> Bool
   {
      if textField == self.apiUrl
      {
         self.password.text = ""
         self.login.text = ""
         self.underlineUsername.backgroundColor = UIColor.lightGray
         self.underlinePassword.backgroundColor = UIColor.lightGray
      }
      return true
   }
   
   @IBAction func loginButtonPressed()
   {
      if !(apiUrl.text?.isEmpty)! && !(login.text?.isEmpty)!
      {
         errorLabel.text = ""
         startLoading()
         Connection.sharedInstance = Connection(login: login.text!, password: password.text ?? "", apiUrl: apiUrl.text!)
         Connection.sharedInstance?.loginView = self
         Connection.sharedInstance?.login(onSuccess: onLoginSuccess, onFailure: onLoginFailure)
      }
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
   
   @objc func apiUrlIsEdited()
   {
      reload()
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
               self.stopLoading(completition: self.presentMainNavigationController)
         }
      }
   }
   
   /**
    * Handler for failed login to NetXMS WebAPI
    */
   func onLoginFailure(data: Any?)
   {
      stopLoading(completition: nil)
      if let response = data as? HTTPURLResponse
      {
         DispatchQueue.main.async
         {
            self.errorLabel.text = "Error \(response.statusCode): " + resolveErrorStatusCode(code: response.statusCode)
         }
      }
      else if let response = data as? String
      {
         DispatchQueue.main.async
         {
            self.errorLabel.text = response
         }
      }
   }
   
   func startLoading()
   {
      alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
      let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
      loadingIndicator.hidesWhenStopped = true
      loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
      loadingIndicator.startAnimating();
      alert.view.addSubview(loadingIndicator)
      
      let stopImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
         UIImage(imageLiteralResourceName: "stop").draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
      }
      
      let stopButton = UIButton(type: .system)
      stopButton.setImage(stopImage, for: UIControlState.normal)
      stopButton.frame = CGRect(x: 238, y: 2, width: 30, height: 30)
      stopButton.addTarget(self, action: #selector(onStopButtonPressed), for: UIControlEvents.touchDown)
      stopButton.tintColor = UIColor.black
      alert.view.addSubview(stopButton)
      
      self.present(alert, animated: true, completion: nil)
   }
   
   @objc func onStopButtonPressed()
   {
      Connection.sharedInstance?.dataTask?.cancel()
   }
   
   func stopLoading(completition: (() -> Void)?)
   {
      if alert.isBeingDismissed
      {
         presentMainNavigationController()
      }
      else
      {
         alert.dismiss(animated: true, completion: completition)
      }
   }
   
   func clearPersistantData()
   {
      for key in UserDefaults.standard.dictionaryRepresentation().keys
      {
         UserDefaults.standard.removeObject(forKey: key)
      }
      KeychainWrapper.standard.removeAllKeys()
   }
   
   func presentMainNavigationController()
   {
      let mainNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
      self.present(mainNavigationController, animated: true, completion: nil)
   }
   
   func storeCredentialsInKeyChain()
   {
      if let apiUrl = self.apiUrl.text,
         let login = self.login.text,
         let pass = self.password.text
      {
         let credentials = login + "@" + apiUrl
         let credentialHistorySet = NSMutableOrderedSet(array: credentialHistory)
         if credentialHistorySet.contains(credentials)
         {
            let index = credentialHistorySet.index(of: credentials)
            credentialHistorySet.moveObjects(at: [index], to: 0)
         }
         else
         {
            credentialHistorySet.add(credentials)
         }
         credentialHistory = credentialHistorySet.array as? [String]
         UserDefaults.standard.set(credentialHistory, forKey: "NetXMSApiURLs")
         KeychainWrapper.standard.set(pass, forKey: login)
      }
   }
   
   func loadCredentialsFromKeyChain()
   {
      credentialHistory = UserDefaults.standard.object(forKey: "NetXMSApiURLs") as? [String] ?? [String]()
      filteredCredentialHistory = credentialHistory
      if let lastCred = credentialHistory.first?.components(separatedBy: "@"),
         lastCred.count == 2
      {
         self.login.insertText(lastCred[0])
         self.apiUrl.insertText(lastCred[1])
         if let pass = KeychainWrapper.standard.string(forKey: lastCred[0])
         {
            self.password.insertText(pass)
            loginButtonPressed()
         }
         self.historyTableHeight.constant = 0
      }
   }
   
   func clearCredentialEntry(entry: String)
   {
      if let cred = entry.components(separatedBy: "@") as [String]?,
         cred.count == 2
      {
         KeychainWrapper.standard.removeObject(forKey: cred[0])
         credentialHistory.removeAll(where: { $0.contains(entry) })
         UserDefaults.standard.set(credentialHistory, forKey: "NetXMSApiURLs")
      }
   }
   
   func clearFields()
   {
      self.apiUrl.text = ""
      self.login.text = ""
      self.password.text = ""
   }
}
