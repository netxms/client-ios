//
//  PredefinedGraphViewCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 04/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class PredefinedGraphViewCell: UITableViewCell
{
   @IBOutlet weak var graphIcon: UIImageView!
   @IBOutlet weak var graphName: UILabel!
   
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
