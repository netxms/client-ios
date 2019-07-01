//
//  MainNavigationController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 10/05/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit

class MainNavigationController : UINavigationController
{
   override func viewDidLoad()
   {
      super.viewDidLoad()
    
      self.navigationBar.barTintColor = UIColor.white
      self.navigationBar.shadowImage = UIImage()
      self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
      self.navigationBar.layer.shadowColor = UIColor(red:0.2, green:0.03, blue:0, alpha:0.3).cgColor
      self.navigationBar.layer.shadowOpacity = 0.4
      self.navigationBar.layer.shadowRadius = 4
    
      self.toolbar.tintColor = UIColor.white
      self.toolbar.barTintColor = UIColor.white
      self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
      self.toolbar.layer.shadowOffset = CGSize(width: 0, height: 2)
      self.toolbar.layer.shadowColor = UIColor(red:0.2, green:0.03, blue:0, alpha:0.3).cgColor
      self.toolbar.layer.shadowOpacity = 0.4
      self.toolbar.layer.shadowRadius = 4
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
      tap.cancelsTouchesInView = false
      self.view.addGestureRecognizer(tap)
   }
   
   @objc func dismissKeyboard()
   {
      self.view.endEditing(true)
   }
   
   static func setButtonStyle(button: UIButton)
   {
      button.layer.shadowColor = UIColor(red:0.2, green:0.03, blue:0, alpha:0.3).cgColor
      button.layer.shadowOpacity = 1
      button.layer.shadowOffset = CGSize(width: 0, height: 4)
      button.layer.shadowRadius = 12
      button.layer.cornerRadius = 4
      
      let gradient = CAGradientLayer()
      gradient.frame = button.bounds
      gradient.colors = [
         UIColor(red:0.93, green:0.18, blue:0.14, alpha:1).cgColor,
         UIColor(red:0.96, green:0.46, blue:0.13, alpha:1).cgColor
      ]
      gradient.locations = [0, 1]
      gradient.startPoint = CGPoint(x: 1, y: 0)
      gradient.endPoint = CGPoint(x: 0, y: 1)
      gradient.cornerRadius = 4
      
      if let layer = button.layer.sublayers?[0] as? CAGradientLayer
      {
         button.layer.replaceSublayer(layer, with: gradient)
      }
      else
      {
         button.layer.addSublayer(gradient)
      }
   }
}
