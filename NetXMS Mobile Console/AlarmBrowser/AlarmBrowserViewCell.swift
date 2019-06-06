//
//  AlarmBrowserViewCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 27/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class AlarmBrowserViewCell: UITableViewCell
{
   @IBOutlet weak var containerView: UIView!
   @IBOutlet weak var objectName: UILabel!
   @IBOutlet weak var createdOn: UILabel!
   @IBOutlet weak var message: UILabel!
   @IBOutlet var stateLabel: UILabel!
   var alarm: Alarm?
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
      // Initialization code
   }
   
   func fillCell(alarm: Alarm)
   {
      self.alarm = alarm
      objectName.text = Connection.sharedInstance?.resolveObjectName(objectId: alarm.sourceObjectId)
      message.text = alarm.message
      createdOn.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: alarm.creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      setSeverity()
      setState()
   }
   
   func setState(state: State? = nil)
   {
      if let alarm = alarm
      {
         let alpha: CGFloat = 1
         stateLabel.backgroundColor = UIColor.clear
         stateLabel.layer.cornerRadius = 4
         switch (state != nil ? state : alarm.state)
         {
         case .OUTSTANDING?:
            stateLabel.text = "Outstanding"
            stateLabel.layer.backgroundColor = UIColor(red: 1, green: 0.627, blue: 0, alpha: alpha).cgColor
         case .ACKNOWLEDGED?:
            stateLabel.text = "Acknowledged"
            stateLabel.layer.backgroundColor = UIColor(red: 0.686, green: 0.706, blue: 0.169, alpha: alpha).cgColor
         case .RESOLVED?:
            stateLabel.text = "Resolved"
            stateLabel.layer.backgroundColor = UIColor(red: 0.376, green: 0.490, blue: 0.545, alpha: alpha).cgColor
         case .TERMINATED?:
            stateLabel.text = "Terminated"
            stateLabel.layer.backgroundColor = UIColor(red: 180, green: 0, blue: 0, alpha: alpha).cgColor
         case .ACKNOWLEDGED_STICKY?:
            stateLabel.text = "Acknowledged"
            stateLabel.layer.backgroundColor = UIColor(red: 0.686, green: 0.706, blue: 0.169, alpha: alpha).cgColor
         default:
            stateLabel.text = "Unknown"
            stateLabel.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: alpha).cgColor
         }
      }
   }
   
   func setSeverity()
   {
      if let alarm = alarm
      {
         createdOn.backgroundColor = UIColor.clear
         createdOn.layer.cornerRadius = 4
         let alpha: CGFloat = 1
         switch alarm.currentSeverity
         {
         case .NORMAL:
            createdOn.layer.backgroundColor = UIColor(red: 0, green: 192, blue: 0, alpha: alpha).cgColor
         case .WARNING:
            createdOn.layer.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: alpha).cgColor
         case .MINOR:
            createdOn.layer.backgroundColor = UIColor(red: 231, green: 226, blue: 0, alpha: alpha).cgColor
         case .MAJOR:
            createdOn.layer.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: alpha).cgColor
         case .CRITICAL:
            createdOn.layer.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: alpha).cgColor
         case .UNKNOWN:
            createdOn.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: alpha).cgColor
         case .TERMINATE:
            createdOn.layer.backgroundColor = UIColor(red: 139, green: 0, blue: 0, alpha: alpha).cgColor
         case .RESOLVE:
            createdOn.layer.backgroundColor = UIColor(red: 0, green: 128, blue: 0, alpha: alpha).cgColor
         }
      }
   }
}
