//
//  LastValuesswift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 30/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class LastValuesCell: UITableViewCell
{
   var dciValue: DciValue!
   @IBOutlet weak var statusLabel: UILabel!
   @IBOutlet weak var dciName: UILabel!
   @IBOutlet weak var timestamp: UILabel!
   @IBOutlet weak var value: UILabel!
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
      value.sizeToFit()
   }
   
   func fillCell(value: DciValue)
   {
      dciValue = value
      dciName.text = dciValue.description
      timestamp.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: dciValue.timestamp), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      if dciValue.value == Double(-1)
      {
         self.value.text = "<ERROR>"
         self.value.textColor = UIColor.red
      }
      else
      {
         let formatter = LargeValueFormatter()
         self.value.text = formatter.stringForValue(dciValue.value, axis: nil)
         self.value.textColor = UIColor.black
      }
      
      if let activeThreshold = dciValue.activeThreshold
      {
         statusLabel.backgroundColor = UIColor.clear
         statusLabel.layer.cornerRadius = 4
         switch activeThreshold.currentSeverity
         {
         case Severity.NORMAL:
            statusLabel.text = "Normal"
            statusLabel.layer.backgroundColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100).cgColor
         case Severity.WARNING:
            statusLabel.text = "Warning"
            statusLabel.layer.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100).cgColor
         case Severity.MINOR:
            statusLabel.text = "Minor"
            statusLabel.layer.backgroundColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100).cgColor
         case Severity.MAJOR:
            statusLabel.text = "Major"
            statusLabel.layer.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100).cgColor
         case Severity.CRITICAL:
            statusLabel.text = "Critical"
            statusLabel.layer.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100).cgColor
         case Severity.UNKNOWN:
            statusLabel.text = "Unknown"
            statusLabel.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100).cgColor
         case Severity.TERMINATE:
            statusLabel.text = "Terminate"
            statusLabel.layer.backgroundColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100).cgColor
         case Severity.RESOLVE:
            statusLabel.text = "Resolve"
            statusLabel.layer.backgroundColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100).cgColor
         }
      }
      else
      {
         statusLabel.layer.backgroundColor = UIColor.clear.cgColor
         statusLabel.text = ""
      }
   }
   
   override func setSelected(_ selected: Bool, animated: Bool)
   {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
}
