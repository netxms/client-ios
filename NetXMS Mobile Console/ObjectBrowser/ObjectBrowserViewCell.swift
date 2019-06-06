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
   @IBOutlet weak var view: UIView!
   @IBOutlet weak var severityLabel: UILabel!
   @IBOutlet weak var objectName: UILabel!
   @IBOutlet weak var typeImage: UIImageView!
   @IBOutlet var buttonWidth: NSLayoutConstraint!
   @IBOutlet var nameTrailing: NSLayoutConstraint!
   @IBOutlet var nextImage: UIImageView!
   var objectBrowser: ObjectBrowserViewController?
   var object: AbstractObject?
   
   override func awakeFromNib()
   {
      super.awakeFromNib()
      view.layer.cornerRadius = 4
      view.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      view.layer.shadowOpacity = 1
      view.layer.shadowOffset = CGSize(width: 0, height: 2)
      view.layer.shadowRadius = 4
   }
   
   override func setSelected(_ selected: Bool, animated: Bool)
   {
      super.setSelected(selected, animated: animated)
   }
   
   @IBAction func onButtonPressed(_ sender: Any)
   {
      if let objectBrowserVC = objectBrowser?.storyboard?.instantiateViewController(withIdentifier: "ObjectBrowserViewController") as? ObjectBrowserViewController,
         let object = object
      {
         objectBrowserVC.parentId = object.objectId
         objectBrowser?.navigationController?.pushViewController(objectBrowserVC, animated: true)
      }
   }
   
   func fillCell(object: AbstractObject, view: ObjectBrowserViewController)
   {
      self.object = object
      objectBrowser = view
      
      objectName.text = object.objectName
      setArrow()
      setIcon()
      setStatus()
   }
   
   func setArrow()
   {
      if let object = object,
         object.objectClass == .OBJECT_CONTAINER || object.objectClass == .OBJECT_SUBNET
      {
         buttonWidth.constant = CGFloat(80)
         nameTrailing.constant = CGFloat(42)
         nextImage.isHidden = false
      }
      else
      {
         buttonWidth.constant = CGFloat(0)
         nextImage.isHidden = true
      }
   }
   
   func setIcon()
   {
      if let object = object
      {
         switch object.objectClass
         {
         case .OBJECT_NODE:
            typeImage.image = UIImage(imageLiteralResourceName: "node")
         case .OBJECT_CLUSTER:
            typeImage.image = UIImage(imageLiteralResourceName: "cluster")
         case .OBJECT_CONTAINER:
            typeImage.image = UIImage(imageLiteralResourceName: "container")
         case .OBJECT_RACK:
            typeImage.image = UIImage(imageLiteralResourceName: "rack")
         case .OBJECT_SUBNET:
            typeImage.image = UIImage(imageLiteralResourceName: "subnet")
         case .OBJECT_MOBILEDEVICE:
            typeImage.image = UIImage(imageLiteralResourceName: "mobile")
         default:
            break
         }
      }
   }
   
   func setStatus()
   {
      if let object = object
      {
         switch object.status
         {
         case .NORMAL:
            severityLabel.text = "Normal"
            severityLabel.textColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
         case .WARNING:
            severityLabel.text = "Warning"
            severityLabel.textColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
         case .MINOR:
            severityLabel.text = "Minor"
            severityLabel.textColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
         case .MAJOR:
            severityLabel.text = "Major"
            severityLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100)
         case .CRITICAL:
            severityLabel.text = "Critical"
            severityLabel.textColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
         case .UNKNOWN:
            severityLabel.text = "Unknown"
            severityLabel.textColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
         }
      }
   }
}
