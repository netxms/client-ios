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
   var login: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
   var url: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 14))
   
   override init(style: UITableViewCellStyle, reuseIdentifier: String?)
   {
      super.init(style: style, reuseIdentifier: reuseIdentifier)

      backgroundColor = UIColor(red: 0.92, green: 0.94, blue: 0.96, alpha: 0.8)
      //urlLabel.text = "url"
      url.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
      url.textAlignment = .left
      url.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8)
      url.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 16)
      url.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
      addSubview(url)
      
      //loginLabel.text = "login"
      login.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
      login.textColor = UIColor.lightGray
      login.textAlignment = .left
      login.topAnchor.constraint(equalTo: url.bottomAnchor, constant: 2)
      login.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 6)
      login.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 16)
      login.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
      addSubview(login)
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
   }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
      super.setSelected(selected, animated: animated)
    }
}
