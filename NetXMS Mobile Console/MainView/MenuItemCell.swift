//
//  MenuItemCell.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 23/05/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
   @IBOutlet var name: UILabel!
   @IBOutlet var label: UIImageView!
   @IBOutlet var view: UIView!
   
    override func awakeFromNib()
    {
      super.awakeFromNib()
      view.layer.cornerRadius = 4
      view.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      view.layer.shadowOpacity = 1
      view.layer.shadowOffset = CGSize(width: 0, height: 2)
      view.layer.shadowRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
