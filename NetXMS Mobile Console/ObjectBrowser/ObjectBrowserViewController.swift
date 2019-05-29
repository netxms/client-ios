//
//  ObjectBrowserViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 14/06/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectBrowserViewController: UITableViewController, UISearchBarDelegate
{
   @IBOutlet weak var searchBar: UISearchBar!
   var objects: [AbstractObject]!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      if objects == nil
      {
         objects = Connection.sharedInstance?.getTopLevelObjects()
         title = "Root"
      }
      objects = sortObjects(objects: objects)
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
      
      NotificationCenter.default.addObserver(self, selector: #selector(onObjectChange), name: .objectChanged, object: nil)
   }
   
   @objc func onObjectChange()
   {
      refresh()
   }
   
   func sortObjects(objects: [AbstractObject]) -> [AbstractObject]
   {
      let objectList = (objects.sorted
      {
         return ($0.objectName.lowercased()) < ($1.objectName.lowercased())
      })
      
      return objectList.sorted(by: { (o1, o2) -> Bool in
         if (o1.objectClass == ObjectClass.OBJECT_NODE && o2.objectClass != ObjectClass.OBJECT_NODE) || (o1.objectClass == ObjectClass.OBJECT_CLUSTER && o2.objectClass != ObjectClass.OBJECT_CLUSTER) || (o1.objectClass == ObjectClass.OBJECT_RACK && o2.objectClass != ObjectClass.OBJECT_RACK)
         {
            return false
         }
         if (o1.objectClass != ObjectClass.OBJECT_NODE && o2.objectClass == ObjectClass.OBJECT_NODE) || (o1.objectClass != ObjectClass.OBJECT_CLUSTER && o2.objectClass == ObjectClass.OBJECT_CLUSTER) || (o1.objectClass != ObjectClass.OBJECT_RACK && o2.objectClass == ObjectClass.OBJECT_RACK)
         {
            return true
         }
         return (o1.objectName.lowercased()) < (o2.objectName.lowercased())
      })
   }
   
   func refresh()
   {
      objects = sortObjects(objects: Connection.sharedInstance?.getTopLevelObjects() ?? [])
      self.tableView.reloadData()
   }
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
   {
      if searchText == ""
      {
         refresh()
         return
      }
      else
      {
         objects = objects.filter
         {
            (object) -> Bool in
            if searchText.hasPrefix(">") || searchText.hasPrefix("#") || searchText.hasPrefix("/") || searchText.hasPrefix("@")
            {
               var searchText = searchText
               if searchText.first == ">" // Search by IP
               {
                  if let node = object as? Node
                  {
                     searchText.removeFirst()
                     return node.primaryIP.localizedCaseInsensitiveContains(searchText)
                  }
               }
               else if searchText.first == "#" // Search by ID
               {
                  searchText.removeFirst()
                  return object.objectId.description.localizedCaseInsensitiveContains(searchText)
               }
               else if searchText.first == "/" // Search by comment
               {
                  searchText.removeFirst()
                  return object.comments.localizedCaseInsensitiveContains(searchText)
               }
               else if searchText.first == "@" // Search by zone ID
               {
                  if let node = object as? Node
                  {
                     searchText.removeFirst()
                     return node.zoneId.description.localizedCaseInsensitiveContains(searchText)
                  }
               }
            }
            
            return object.objectName.localizedCaseInsensitiveContains(searchText)
         }
      }
      self.tableView.reloadData()
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return objects.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath) as! ObjectBrowserViewCell
      cell.object = self.objects[indexPath.row]
      cell.objectBrowser = self
      cell.objectName?.text = self.objects[indexPath.row].objectName
      
      if self.objects[indexPath.row].objectClass == ObjectClass.OBJECT_NODE
      {
         cell.buttonWidth.constant = CGFloat(0)
         cell.nameTrailing.constant = CGFloat(16)
         cell.nextImage.isHidden = true
      }
      else
      {
         cell.buttonWidth.constant = CGFloat(100)
      }
      
      switch self.objects[indexPath.row].objectClass
      {
      case ObjectClass.OBJECT_NODE:
         cell.typeImage.image = UIImage(imageLiteralResourceName: "node")
      case ObjectClass.OBJECT_CLUSTER:
         cell.typeImage.image = UIImage(imageLiteralResourceName: "cluster")
      case ObjectClass.OBJECT_CONTAINER:
         cell.typeImage.image = UIImage(imageLiteralResourceName: "container")
      case ObjectClass.OBJECT_RACK:
         cell.typeImage.image = UIImage(imageLiteralResourceName: "rack")
      default:
         break
      }
      
      switch self.objects[indexPath.row].status
      {
      case ObjectStatus.NORMAL:
         cell.severityLabel.text = "Normal"
         cell.severityLabel.textColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
      case ObjectStatus.WARNING:
         cell.severityLabel.text = "Warning"
         cell.severityLabel.textColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
      case ObjectStatus.MINOR:
         cell.severityLabel.text = "Minor"
         cell.severityLabel.textColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
      case ObjectStatus.MAJOR:
         cell.severityLabel.text = "Major"
         cell.severityLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100)
      case ObjectStatus.CRITICAL:
         cell.severityLabel.text = "Critical"
         cell.severityLabel.textColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
      case ObjectStatus.UNKNOWN:
         cell.severityLabel.text = "Unknown"
         cell.severityLabel.textColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
      }
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if let objectDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ObjectDetailsViewController")
      {
         (objectDetailsVC as? ObjectDetailsViewController)?.object = self.objects[indexPath.row]
         navigationController?.pushViewController(objectDetailsVC, animated: true)
      }
   }
}
