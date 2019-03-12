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
   @IBOutlet weak var topBar: UINavigationItem!
   @IBOutlet weak var serverLabel: UILabel!
   
   override func viewDidLoad()
   {
      self.navigationController?.setToolbarHidden(true, animated: false)
      
      self.serverLabel.text = "\(Connection.sharedInstance!.session!.userData.name)@\(Connection.sharedInstance!.session!.serverData.address)"
      
      objectsButton.layer.cornerRadius = 4
      objectsButton.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      objectsButton.layer.shadowOpacity = 1
      objectsButton.layer.shadowOffset = CGSize(width: 0, height: 4)
      objectsButton.layer.shadowRadius = 12
      
      alarmsButton.layer.cornerRadius = 4
      alarmsButton.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      alarmsButton.layer.shadowOpacity = 1
      alarmsButton.layer.shadowOffset = CGSize(width: 0, height: 4)
      alarmsButton.layer.shadowRadius = 12
      
      graphsButton.layer.cornerRadius = 4
      graphsButton.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      graphsButton.layer.shadowOpacity = 1
      graphsButton.layer.shadowOffset = CGSize(width: 0, height: 4)
      graphsButton.layer.shadowRadius = 12
      
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
