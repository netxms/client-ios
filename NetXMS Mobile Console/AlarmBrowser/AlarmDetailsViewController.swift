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
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
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
   
   @IBAction func acknowledgePressed(_ sender: Any) {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM)
   }
   
   @IBAction func stickyAcknowledgePressed(_ sender: Any) {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM) // TODO!!!
   }
   
   @IBAction func resolvePressed(_ sender: Any) {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.RESOLVE_ALARM)
   }
   
   @IBAction func terminatePressed(_ sender: Any) {
      Connection.sharedInstance?.modifyAlarm(alarmId: alarm.id, action: AlarmBrowserViewController.TERMINATE_ALARM)
      self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func lastValuesPressed(_ sender: Any) {
      if let lastValuesVC = storyboard?.instantiateViewController(withIdentifier: "LastValuesViewController") as? LastValuesViewController
      {
         lastValuesVC.objectId = self.alarm.sourceObjectId
         navigationController?.pushViewController(lastValuesVC, animated: true)
      }
   }
}
