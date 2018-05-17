//
//  MainViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 10/05/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController
{
   override func viewDidLoad()
   {
      super.viewDidLoad()
   }
   @IBAction func logoutPressed(_ sender: Any)
   {
      print("logout")
      Connection.sharedInstance?.logout(onSuccess: onLogoutSuccess)
   }
   
   func onLogoutSuccess(jsonData: [String : Any]?) -> Void
   {
      DispatchQueue.main.async
      {
         Connection.sharedInstance = nil
         self.presentingViewController?.dismiss(animated: true, completion: nil)
      }
   }
}
