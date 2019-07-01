//
//  ObjectDetailsAlarmCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 12/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectDetailsAlarmCell: UITableViewCell
{
   @IBOutlet weak var severityLabel: UILabel!
   @IBOutlet weak var objectName: UILabel!
   @IBOutlet weak var message: UILabel!
   @IBOutlet weak var createdOn: UILabel!
   var alarm: Alarm?
   
   override func awakeFromNib() {
      super.awakeFromNib()
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
   
   func setState()
   {
      if let alarm = alarm
      {
         let alpha: CGFloat = 1
         severityLabel.backgroundColor = UIColor.clear
         severityLabel.layer.cornerRadius = 4
         switch alarm.state
         {
         case .OUTSTANDING:
            severityLabel.text = "Outstanding"
            severityLabel.layer.backgroundColor = UIColor(red: 1, green: 0.627, blue: 0, alpha: alpha).cgColor
         case .ACKNOWLEDGED:
            severityLabel.text = "Acknowledged"
            severityLabel.layer.backgroundColor = UIColor(red: 0.686, green: 0.706, blue: 0.169, alpha: alpha).cgColor
         case .RESOLVED:
            severityLabel.text = "Resolved"
            severityLabel.layer.backgroundColor = UIColor(red: 0.376, green: 0.490, blue: 0.545, alpha: alpha).cgColor
         case .TERMINATED:
            severityLabel.text = "Terminated"
            severityLabel.layer.backgroundColor = UIColor(red: 180, green: 0, blue: 0, alpha: alpha).cgColor
         case State.ACKNOWLEDGED_STICKY:
            severityLabel.text = "Acknowledged"
            severityLabel.layer.backgroundColor = UIColor(red: 0.686, green: 0.706, blue: 0.169, alpha: alpha).cgColor
         case .UNKNOWN:
            severityLabel.text = "Unknown"
            severityLabel.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: alpha).cgColor
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
   
   override func setSelected(_ selected: Bool, animated: Bool)
   {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
}
