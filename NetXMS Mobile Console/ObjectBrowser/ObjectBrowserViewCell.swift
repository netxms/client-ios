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
         severityLabel.backgroundColor = UIColor.clear
         severityLabel.layer.cornerRadius = 4
         switch object.status
         {
         case .NORMAL:
            severityLabel.text = "Normal"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0, green: 0.6724151373, blue: 0, alpha: 1)
         case .WARNING:
            severityLabel.text = "Warning"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0, green: 0.7642611861, blue: 0.7715749145, alpha: 1)
         case .MINOR:
            severityLabel.text = "Minor"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.8109195232, green: 0.7863419056, blue: 0, alpha: 1)
         case .MAJOR:
            severityLabel.text = "Major"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.8439414501, green: 0.4790760279, blue: 0, alpha: 1)
         case .CRITICAL:
            severityLabel.text = "Critical"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.7659458518, green: 0.1022023931, blue: 0, alpha: 1)
         case .UNKNOWN:
            severityLabel.text = "Unknown"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
         case .UNMANAGED:
            severityLabel.text = "Unmanaged"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
         case .DISABLED:
            severityLabel.text = "Disabled"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.1674376428, green: 0.1674425602, blue: 0.167439878, alpha: 1)
         case .TESTING:
            severityLabel.text = "Testing"
            severityLabel.layer.backgroundColor = #colorLiteral(red: 0.5813295245, green: 0.5770503879, blue: 0.4152996242, alpha: 1)
         }
      }
   }
}
