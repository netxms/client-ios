//
//  CredentialHistoryCell.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 22/05/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit

class CredentialHistoryCell: UITableViewCell
{
   @IBOutlet var url: UILabel!
   @IBOutlet var name: UILabel!
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
   }

   func fillCell(url: String, name: String)
   {
      self.url.text = url
      self.name.text = name
      layer.cornerRadius = 4
   }
}
