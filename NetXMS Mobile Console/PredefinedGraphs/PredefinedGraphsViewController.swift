//
//  PredefinedGraphsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 29/08/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class PredefinedGraphsViewController: UITableViewController, UISearchBarDelegate
{
   @IBOutlet weak var searchBar: UISearchBar!
   var root: GraphFolder!
   var list = [AnyObject]()
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      if self.root == nil,
      let root = Connection.sharedInstance?.predefinedGraphRoot
      {
         self.root = root
      }
      
      title = (root.name == "[root]" ? "Graphs" : root.name)
      for f in root.subfolders
      {
         list.append(f)
      }
      for g in root.graphs
      {
         list.append(g)
      }
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
   }
   
   func refresh()
   {
      if let root = Connection.sharedInstance?.predefinedGraphRoot
      {
         self.root = root
         title = (root.name == "[root]" ? "Graphs" : root.name)
         for f in root.subfolders
         {
            list.append(f)
         }
         for g in root.graphs
         {
            list.append(g)
         }
      }
      self.tableView.reloadData()
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return list.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      let obj = list[indexPath.row]
      
      if obj is GraphSettings,
         let graphCell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath) as? PredefinedGraphViewCell
      {
         graphCell.graphName.text = (obj as! GraphSettings).shortName
         return graphCell
      }
      else if obj is GraphFolder,
         let graphFolderCell = tableView.dequeueReusableCell(withIdentifier: "GraphFolderCell", for: indexPath) as? PredefinedGraphFolderViewCell
      {
         graphFolderCell.folderName.text = (obj as! GraphFolder).name
         return graphFolderCell
      }
      return UITableViewCell()
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      let obj = list[indexPath.row]
      
      if obj as? GraphSettings != nil
      {
         if let predefinedGraphVC = storyboard?.instantiateViewController(withIdentifier: "PredefinedGraphChartController")
         {
            (predefinedGraphVC as! PredefinedGraphChartController).object = obj
            navigationController?.pushViewController(predefinedGraphVC, animated: true)
         }
      }
      else if obj as? GraphFolder != nil
      {
         if let predefinedGraphVC = storyboard?.instantiateViewController(withIdentifier: "PredefinedGraphsViewController")
         {
            (predefinedGraphVC as! PredefinedGraphsViewController).root = obj as? GraphFolder
            navigationController?.pushViewController(predefinedGraphVC, animated: true)
         }
      }
   }
}
