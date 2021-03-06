//
//  GraphFolderViewCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 05/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class PredefinedGraphFolderViewCell: UITableViewCell
{
   @IBOutlet var icon: UIImageView!
   @IBOutlet weak var folderName: UILabel!
   
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
