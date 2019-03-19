//
//  ObjectToolViewCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 19/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectToolViewCell: UITableViewCell
{
   @IBOutlet weak var name: UILabel!
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
   }
   
   override func setSelected(_ selected: Bool, animated: Bool)
   {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
}
