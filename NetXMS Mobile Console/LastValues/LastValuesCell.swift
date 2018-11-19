//
//  LastValuesCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 30/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class LastValuesCell: UITableViewCell
{
   @IBOutlet weak var statusLabel: UILabel!
   @IBOutlet weak var dciName: UILabel!
   @IBOutlet weak var timestamp: UILabel!
   @IBOutlet weak var value: UILabel!
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
      // Initialization code
   }
   
   override func setSelected(_ selected: Bool, animated: Bool)
   {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
}
