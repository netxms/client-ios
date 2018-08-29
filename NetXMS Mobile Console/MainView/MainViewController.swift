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
      alarmsButton.layer.masksToBounds = false
      alarmsButton.layer.shadowColor = UIColor.gray.cgColor
      alarmsButton.layer.shadowOpacity = 0.3
      alarmsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      alarmsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      alarmsButton.layer.shadowPath = UIBezierPath(rect: alarmsButton.bounds).cgPath
      alarmsButton.layer.shouldRasterize = true
      alarmsButton.layer.rasterizationScale = UIScreen.main.scale
      
      objectsButton.layer.masksToBounds = false
      objectsButton.layer.shadowColor = UIColor.gray.cgColor
      objectsButton.layer.shadowOpacity = 0.3
      objectsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      objectsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      objectsButton.layer.shadowPath = UIBezierPath(rect: objectsButton.bounds).cgPath
      objectsButton.layer.shouldRasterize = true
      objectsButton.layer.rasterizationScale = UIScreen.main.scale
      
      graphsButton.layer.masksToBounds = false
      graphsButton.layer.shadowColor = UIColor.gray.cgColor
      graphsButton.layer.shadowOpacity = 0.3
      graphsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      graphsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      graphsButton.layer.shadowPath = UIBezierPath(rect: objectsButton.bounds).cgPath
      graphsButton.layer.shouldRasterize = true
      graphsButton.layer.rasterizationScale = UIScreen.main.scale
      
      super.viewDidLoad()
   }
   @IBAction func logoutPressed(_ sender: Any)
   {
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
