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
   @IBOutlet weak var alarmsButton: UIButton!
   @IBOutlet weak var objectsButton: UIButton!
   @IBOutlet weak var graphsButton: UIButton!
   
   override func viewDidLoad()
   {
      self.navigationController?.setToolbarHidden(true, animated: false)
      
      alarmsButton.layer.masksToBounds = false
      alarmsButton.layer.shadowColor = UIColor.gray.cgColor
      alarmsButton.layer.shadowOpacity = 0.3
      alarmsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      alarmsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      objectsButton.layer.masksToBounds = false
      objectsButton.layer.shadowColor = UIColor.gray.cgColor
      objectsButton.layer.shadowOpacity = 0.3
      objectsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      objectsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      graphsButton.layer.masksToBounds = false
      graphsButton.layer.shadowColor = UIColor.gray.cgColor
      graphsButton.layer.shadowOpacity = 0.3
      graphsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      graphsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      self.title = "NetXMS Mobile Console"
      
      super.viewDidLoad()
   }
   @IBAction func logoutPressed(_ sender: Any)
   {
      Connection.sharedInstance?.logout(onSuccess: onLogoutSuccess)
      self.presentingViewController?.dismiss(animated: true, completion: nil)
      Connection.sharedInstance = nil
   }
   
   func onLogoutSuccess(jsonData: [String : Any]?) -> Void
   {
   }
}
