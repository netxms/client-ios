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
   var objects = [AbstractObject]()
   
    override func viewDidLoad()
    {
      super.viewDidLoad()
      Connection.sharedInstance?.objectBrowser = self
      if objects.count == 0
      {
         objects = (Connection.sharedInstance?.getSortedRootObjects())!
         title = "Root"
      }
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
    }
   
   func refresh()
   {
      for (_,value) in (Connection.sharedInstance?.rootObjects)!
      {
         objects.append(value)
      }
      objects = objects.sorted {
         return ($0.objectName.lowercased()) < ($1.objectName.lowercased())
      }
      self.tableView.reloadData()
   }
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
   {
      if searchText == ""
      {
         objects = (Connection.sharedInstance?.getSortedRootObjects())!
      }
      else
      {
         objects = (Connection.sharedInstance?.getSortedRootObjects())!.filter { (object) -> Bool in
            if searchText.hasPrefix(">") || searchText.hasPrefix("#") || searchText.hasPrefix("/") || searchText.hasPrefix("@")
            {
               var searchText = searchText
               if searchText.first == ">" // Search by IP
               {
                  if object.objectClass == AbstractObject.OBJECT_NODE
                  {
                     searchText.remove(at: searchText.startIndex)
                     if (object as? Node)?.primaryIP.range(of: searchText) != nil
                     {
                        return true
                     }
                  }
               }
               else if searchText.first == "#" // Search by ID
               {
                  searchText.remove(at: searchText.startIndex)
                  if object.objectId.description.range(of: searchText) != nil
                  {
                     return true
                  }
               }
               else if searchText.first == "/" // Search by comment
               {
                  searchText.remove(at: searchText.startIndex)
                  if object.comments.lowercased().range(of: searchText.lowercased()) != nil
                  {
                     return true
                  }
               }
               else if searchText.first == "@" // Search by zone ID
               {
                  if object.objectClass == AbstractObject.OBJECT_NODE
                  {
                     searchText.remove(at: searchText.startIndex)
                     if (object as? Node)?.zoneId.description.range(of: searchText) != nil
                     {
                        return true
                     }
                  }
               }
            }
            else
            {
               if object.objectName.lowercased().range(of: searchText.lowercased()) != nil
               {
                  return true
               }
            }
            return false
         }
      }
      self.tableView.reloadData()
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath) as! ObjectBrowserViewCell
      cell.object = self.objects[indexPath.row]
      cell.objectBrowser = self
      cell.objectName?.text = Connection.sharedInstance?.resolveObjectName(objectId: self.objects[indexPath.row].objectId)
      
      if self.objects[indexPath.row].objectClass == AbstractObject.OBJECT_NODE
      {
         cell.button.isHidden = true
      }
      else
      {
         cell.button.isHidden = false
      }
      
      switch self.objects[indexPath.row].objectClass
      {
      case AbstractObject.OBJECT_NODE:
         cell.typeImage.image = #imageLiteral(resourceName: "node.png")
      case AbstractObject.OBJECT_CLUSTER:
         cell.typeImage.image = #imageLiteral(resourceName: "cluster.png")
      case AbstractObject.OBJECT_CONTAINER:
         cell.typeImage.image = #imageLiteral(resourceName: "container.png")
      default:
         break
      }
      
      switch self.objects[indexPath.row].status
      {
      case ObjectStatus.NORMAL:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
      case ObjectStatus.WARNING:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
      case ObjectStatus.MINOR:
         cell.severityLabel.backgroundColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
      case ObjectStatus.MAJOR:
         cell.severityLabel.backgroundColor = UIColor(red: 255, green: 128, blue: 0, alpha: 100)
      case ObjectStatus.CRITICAL:
         cell.severityLabel.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
      case ObjectStatus.UNKNOWN:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
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
