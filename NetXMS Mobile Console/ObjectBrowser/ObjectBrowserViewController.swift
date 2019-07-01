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
   var parentId = 0
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      refresh()
      
      NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .objectChanged, object: nil)
   
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
   }
   
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
   {
      searchBar.resignFirstResponder()
   }
   
   func sortObjects()
   {
       self.objects = self.objects.sorted(by: { (o1, o2) -> Bool in
         if o1.objectClass == .OBJECT_CONTAINER && o2.objectClass != .OBJECT_CONTAINER
         {
            return true
         }
         if o1.objectClass != .OBJECT_CONTAINER && o2.objectClass == .OBJECT_CONTAINER
         {
            return false
         }
         if o1.objectName.lowercased() < o2.objectName.lowercased()
         {
            return true
         }
         return false
      })
   }
   
   @objc func refresh()
   {
      if parentId == 0
      {
         objects = Connection.sharedInstance?.getTopLevelObjects() ?? []
         self.title = "Objects"
      }
      else
      {
         let parent = Connection.sharedInstance?.objectCache[parentId]
         objects = Array((Connection.sharedInstance?.objectCache.filter { return (parent?.children.contains($0.key))! })!.values)
         self.title = parent?.objectName
      }
      sortObjects()
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
      if let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath) as? ObjectBrowserViewCell
      {
         cell.fillCell(object: self.objects[indexPath.row], view: self)
         return cell
      }
      
      return UITableViewCell()
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
