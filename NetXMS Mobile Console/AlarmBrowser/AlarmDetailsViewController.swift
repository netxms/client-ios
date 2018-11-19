//
//  AlarmDetailsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 11/05/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit

class AlarmDetailsViewController : UIViewController
{
   var alarm: Alarm!   
   @IBOutlet weak var objectName: UILabel!
   @IBOutlet weak var createdOn: UILabel!
   @IBOutlet weak var message: UILabel!
   @IBOutlet weak var severityLabel: UILabel!
   @IBOutlet weak var acknowledgeButton: UIButton!
   @IBOutlet weak var stickyAcknowledgeButton: UIButton!
   @IBOutlet weak var resolveButton: UIButton!
   @IBOutlet weak var terminateButton: UIButton!
   @IBOutlet weak var lastValuesButton: UIButton!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      acknowledgeButton.layer.masksToBounds = false
      acknowledgeButton.layer.shadowColor = UIColor.gray.cgColor
      acknowledgeButton.layer.shadowOpacity = 0.3
      acknowledgeButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      acknowledgeButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      acknowledgeButton.layer.shadowPath = UIBezierPath(rect: acknowledgeButton.bounds).cgPath
      acknowledgeButton.layer.shouldRasterize = true
      acknowledgeButton.layer.rasterizationScale = UIScreen.main.scale
      
      stickyAcknowledgeButton.layer.masksToBounds = false
      stickyAcknowledgeButton.layer.shadowColor = UIColor.gray.cgColor
      stickyAcknowledgeButton.layer.shadowOpacity = 0.3
      stickyAcknowledgeButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      stickyAcknowledgeButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      stickyAcknowledgeButton.layer.shadowPath = UIBezierPath(rect: stickyAcknowledgeButton.bounds).cgPath
      stickyAcknowledgeButton.layer.shouldRasterize = true
      stickyAcknowledgeButton.layer.rasterizationScale = UIScreen.main.scale
      
      resolveButton.layer.masksToBounds = false
      resolveButton.layer.shadowColor = UIColor.gray.cgColor
      resolveButton.layer.shadowOpacity = 0.3
      resolveButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      resolveButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      resolveButton.layer.shadowPath = UIBezierPath(rect: resolveButton.bounds).cgPath
      resolveButton.layer.shouldRasterize = true
      resolveButton.layer.rasterizationScale = UIScreen.main.scale
      
      terminateButton.layer.masksToBounds = false
      terminateButton.layer.shadowColor = UIColor.gray.cgColor
      terminateButton.layer.shadowOpacity = 0.3
      terminateButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      terminateButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      terminateButton.layer.shadowPath = UIBezierPath(rect: terminateButton.bounds).cgPath
      terminateButton.layer.shouldRasterize = true
      terminateButton.layer.rasterizationScale = UIScreen.main.scale
      
      lastValuesButton.layer.masksToBounds = false
      lastValuesButton.layer.shadowColor = UIColor.gray.cgColor
      lastValuesButton.layer.shadowOpacity = 0.3
      lastValuesButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      lastValuesButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      lastValuesButton.layer.shadowPath = UIBezierPath(rect: lastValuesButton.bounds).cgPath
      lastValuesButton.layer.shouldRasterize = true
      lastValuesButton.layer.rasterizationScale = UIScreen.main.scale
      
      objectName.text = Connection.sharedInstance?.resolveObjectName(objectId: alarm.sourceObjectId)
      createdOn.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: alarm.creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      message.text = alarm.message
      
      switch alarm.currentSeverity
      {
      case Severity.NORMAL:
         severityLabel.backgroundColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
      case Severity.WARNING:
         severityLabel.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
      case Severity.MINOR:
         severityLabel.backgroundColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
      case Severity.MAJOR:
         severityLabel.backgroundColor = UIColor(red: 255, green: 128, blue: 0, alpha: 100)
      case Severity.CRITICAL:
         severityLabel.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
      case Severity.UNKNOWN:
         severityLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
      case Severity.TERMINATE:
         severityLabel.backgroundColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100)
      case Severity.RESOLVE:
         severityLabel.backgroundColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100)
      }
   }
   
   @IBAction func acknowledgePressed(_ sender: Any)
   {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM)
   }
   
   @IBAction func stickyAcknowledgePressed(_ sender: Any)
   {
      showTimeoutDialog(alarmId: alarm.id)
   }
   
   @IBAction func resolvePressed(_ sender: Any)
   {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.RESOLVE_ALARM)
   }
   
   @IBAction func terminatePressed(_ sender: Any)
   {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.TERMINATE_ALARM)
      self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func lastValuesPressed(_ sender: Any)
   {
      if let lastValuesVC = storyboard?.instantiateViewController(withIdentifier: "LastValuesViewController") as? LastValuesViewController
      {
         lastValuesVC.objectId = self.alarm.sourceObjectId
         navigationController?.pushViewController(lastValuesVC, animated: true)
      }
   }
   
   func showTimeoutDialog(alarmId: Int)
   {
      //Creating UIAlertController and
      //Setting title and message for the alert dialog
      let alertController = UIAlertController(title: "Choose timeout", message: "Choose timeout for sticky acknowledge", preferredStyle: .alert)
      
      //the confirm action taking the inputs
      let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
         //getting the input values from user
         let timeout = alertController.textFields?[0].text
         if let timeoutString = timeout,
            let timeout = Int(timeoutString)
         {
            Connection.sharedInstance?.modifyAlarm(alarmId: self.alarm.id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM, timeout: timeout)
         }
      }
      
      //the cancel action doing nothing
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
      
      //adding textfields to our dialog box
      alertController.addTextField { (textField) in
         textField.placeholder = "Timeout"
      }
      
      //adding the action to dialogbox
      alertController.addAction(confirmAction)
      alertController.addAction(cancelAction)
      
      //finally presenting the dialog box
      self.present(alertController, animated: true, completion: nil)
   }
}
