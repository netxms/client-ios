//
//  ObjectBrowserViewCell.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 14/06/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectBrowserViewCell: UITableViewCell
{
   @IBOutlet weak var severityLabel: UILabel!
   @IBOutlet weak var objectName: UILabel!
   @IBOutlet weak var button: UIButton!
   @IBOutlet weak var typeImage: UIImageView!
   var object: AbstractObject?
   var objectBrowser: ObjectBrowserViewController?
   
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
   
   @IBAction func onButtonPressed(_ sender: Any)
   {
      if let objectBrowserVC = objectBrowser?.storyboard?.instantiateViewController(withIdentifier: "ObjectBrowserViewController")
      {
         var objects = [AbstractObject]()
         for id in (object?.children)!
         {
            if let child = Connection.sharedInstance?.objectCache[id]
            {
               objects.append(child)
            }
         }
         objectBrowserVC.title = object?.objectName
         (objectBrowserVC as? ObjectBrowserViewController)?.objects = objects
         objectBrowser?.navigationController?.pushViewController(objectBrowserVC, animated: true)
      }
   }
}
