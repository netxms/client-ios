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
   @IBOutlet weak var message: UITextView!
   @IBOutlet weak var severityLabel: UILabel!
   @IBOutlet weak var acknowledgeButton: UIButton!
   @IBOutlet weak var stickyAcknowledgeButton: UIButton!
   @IBOutlet weak var resolveButton: UIButton!
   @IBOutlet weak var terminateButton: UIButton!
   @IBOutlet weak var lastValuesButton: UIButton!
   let blackView = UIView()
   @IBOutlet weak var buttonStack: UIStackView!
   @IBOutlet weak var contentView: UIView!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      objectName.text = Connection.sharedInstance?.resolveObjectName(objectId: alarm.sourceObjectId)
      self.title = objectName.text
      createdOn.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: alarm.creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      message.text = alarm.message

      switch alarm.currentSeverity
      {
      case Severity.NORMAL:
         severityLabel.text = "Normal"
         severityLabel.textColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
      case Severity.WARNING:
         severityLabel.text = "Warning"
         severityLabel.textColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
      case Severity.MINOR:
         severityLabel.text = "Minor"
         severityLabel.textColor = UIColor(red:0.84, green:0.7, blue:0, alpha:1)
      case Severity.MAJOR:
         severityLabel.text = "Major"
         severityLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100)
      case Severity.CRITICAL:
         severityLabel.text = "Critical"
         severityLabel.textColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
      case Severity.UNKNOWN:
         severityLabel.text = "Unknown"
         severityLabel.textColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
      case Severity.TERMINATE:
         severityLabel.text = "Terminate"
         severityLabel.textColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100)
      case Severity.RESOLVE:
         severityLabel.text = "Resolve"
         severityLabel.textColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100)
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
      
      let actionsBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(openMenu))
      self.navigationItem.rightBarButtonItem = actionsBarButtonItem
      self.buttonStack.isHidden = true
   }
   
   @objc func openMenu()
   {
      self.buttonStack.isHidden = false
      blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
      
      blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
      
      contentView.addSubview(blackView)
      //view.addSubview(collectionView)
      let height: CGFloat = self.buttonStack.frame.height + 16
      let y = self.view.frame.height - height
      buttonStack.frame = CGRect(x: 16, y: self.view.frame.height, width: self.view.frame.width, height: height)
      
      blackView.frame = view.frame
      blackView.alpha = 0
      
      UIView.animate(withDuration: 0.5, animations: {
         self.blackView.alpha = 1
         self.buttonStack.frame = CGRect(x: 16, y: y, width: self.view.frame.width, height: self.view.frame.height)
         })
   }
   
   @objc func handleDismiss()
   {
      UIView.animate(withDuration: 0.5, animations: {
         self.blackView.alpha = 0
         self.buttonStack.frame = CGRect(x: 16, y: self.view.frame.height, width: self.buttonStack.frame.width, height: self.buttonStack.frame.height)
      })
   }
   
   override func viewDidLayoutSubviews()
   {
      let buttonList = [acknowledgeButton, stickyAcknowledgeButton, resolveButton, terminateButton, lastValuesButton]
      for button in buttonList
      {
         MainNavigationController.setButtonStyle(button: button!)
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
