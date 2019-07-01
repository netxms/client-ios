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
   var state: State?
   
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
         self.state = state
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
         switch alarm.currentSeverity
         {
         case .NORMAL:
            createdOn.layer.backgroundColor = #colorLiteral(red: 0, green: 0.6724151373, blue: 0, alpha: 1)
         case .WARNING:
            createdOn.layer.backgroundColor = #colorLiteral(red: 0, green: 0.7642611861, blue: 0.7715749145, alpha: 1)
         case .MINOR:
            createdOn.layer.backgroundColor = #colorLiteral(red: 0.8109195232, green: 0.7863419056, blue: 0, alpha: 1)
         case .MAJOR:
            createdOn.layer.backgroundColor = #colorLiteral(red: 0.8439414501, green: 0.4790760279, blue: 0, alpha: 1)
         case .CRITICAL:
            createdOn.layer.backgroundColor = #colorLiteral(red: 0.7659458518, green: 0.1022023931, blue: 0, alpha: 1)
         case .UNKNOWN:
            createdOn.layer.backgroundColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
         case .TERMINATE:
            createdOn.layer.backgroundColor = UIColor(red: 180, green: 0, blue: 0, alpha: alpha).cgColor
         case .RESOLVE:
            createdOn.layer.backgroundColor = UIColor(red: 0.376, green: 0.490, blue: 0.545, alpha: alpha).cgColor
         }
      }
   }
}
