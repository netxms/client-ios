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
      acknowledgeButton.layer.shadowOpacity = 0.5
      acknowledgeButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      acknowledgeButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      stickyAcknowledgeButton.layer.masksToBounds = false
      stickyAcknowledgeButton.layer.shadowColor = UIColor.gray.cgColor
      stickyAcknowledgeButton.layer.shadowOpacity = 0.5
      stickyAcknowledgeButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      stickyAcknowledgeButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      resolveButton.layer.masksToBounds = false
      resolveButton.layer.shadowColor = UIColor.gray.cgColor
      resolveButton.layer.shadowOpacity = 0.5
      resolveButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      resolveButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      terminateButton.layer.masksToBounds = false
      terminateButton.layer.shadowColor = UIColor.gray.cgColor
      terminateButton.layer.shadowOpacity = 0.5
      terminateButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      terminateButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      lastValuesButton.layer.masksToBounds = false
      lastValuesButton.layer.shadowColor = UIColor.gray.cgColor
      lastValuesButton.layer.shadowOpacity = 0.5
      lastValuesButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      lastValuesButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      objectName.text = Connection.sharedInstance?.resolveObjectName(objectId: alarm.sourceObjectId)
      self.title = objectName.text
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
      
      if alarm.state == Alarm.STATE_ACKNOWLEDGED || alarm.state == Alarm.STATE_ACKNOWLEDGED_STICKY
      {
         acknowledgeButton.isHidden = true
         stickyAcknowledgeButton.isHidden = true
      }
      else if alarm.state == Alarm.STATE_RESOLVED
      {
         acknowledgeButton.isHidden = true
         stickyAcknowledgeButton.isHidden = true
         resolveButton.isHidden = true
      }
   }
   
   @IBAction func acknowledgePressed(_ sender: Any)
   {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM)
      self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func stickyAcknowledgePressed(_ sender: Any)
   {
      showTimeoutDialog(alarmId: alarm.id)
      self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func resolvePressed(_ sender: Any)
   {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.RESOLVE_ALARM)
      self.navigationController?.popViewController(animated: true)
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
            var timeout = Int(timeoutString)
         {
            timeout = timeout * 3600 // To convert in hours
            Connection.sharedInstance?.modifyAlarm(alarmId: self.alarm.id, action: AlarmBrowserViewController.STICKY_ACKNOWLEDGE_ALARM, timeout: timeout)
         }
      }
      
      //the cancel action doing nothing
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
      
      //adding textfields to our dialog box
      alertController.addTextField { (textField) in
         textField.placeholder = "Timeout (in hours)"
      }
      
      //adding the action to dialogbox
      alertController.addAction(confirmAction)
      alertController.addAction(cancelAction)
      
      //finally presenting the dialog box
      self.present(alertController, animated: true, completion: nil)
   }
}
