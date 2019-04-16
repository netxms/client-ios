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
      
      Connection.sharedInstance?.objectBrowser = self
      if objects == nil
      {
         objects = getObjects()
         title = "Root"
      }
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
   }
   
   func getObjects() -> [AbstractObject]
   {
      let objectList = (Connection.sharedInstance?.getFilteredObjects(filter: [ObjectClass.OBJECT_NODE, ObjectClass.OBJECT_CLUSTER, ObjectClass.OBJECT_CONTAINER]) ?? []).sorted
      {
         return ($0.objectName.lowercased()) < ($1.objectName.lowercased())
      }
      
      return objectList.sorted(by: { (o1, o2) -> Bool in
         if o1.objectClass == ObjectClass.OBJECT_NODE && o2.objectClass != ObjectClass.OBJECT_NODE
         {
            return false
         }
         if o1.objectClass != ObjectClass.OBJECT_NODE && o2.objectClass == ObjectClass.OBJECT_NODE
         {
            return true
         }
         return (o1.objectName.lowercased()) < (o2.objectName.lowercased())
      })
   }
   
   func refresh()
   {
      objects = getObjects()
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
         objects = getObjects().filter
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
      }
      else
      {
         cell.buttonWidth.constant = CGFloat(50)
         cell.nameTrailing.constant = CGFloat(42)
      }
      
      switch self.objects[indexPath.row].objectClass
      {
      case ObjectClass.OBJECT_NODE:
         cell.typeImage.image = #imageLiteral(resourceName: "node.png")
      case ObjectClass.OBJECT_CLUSTER:
         cell.typeImage.image = #imageLiteral(resourceName: "cluster.png")
      case ObjectClass.OBJECT_CONTAINER:
         cell.typeImage.image = #imageLiteral(resourceName: "container.png")
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
