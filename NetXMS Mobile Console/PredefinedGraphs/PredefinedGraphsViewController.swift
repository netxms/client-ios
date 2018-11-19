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
      Connection.sharedInstance?.predefinedGraphsBrowser = self
      if self.root == nil
      {
         if let root = Connection.sharedInstance?.predefinedGraphRoot
         {
            self.root = root
            title = "Root"
            for f in root.subfolders
            {
               list.append(f)
            }
            for g in root.graphs
            {
               list.append(g)
            }
         }
      }
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
   }
   
   override func didReceiveMemoryWarning()
   {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func refresh()
   {
      if let root = Connection.sharedInstance?.predefinedGraphRoot
      {
         self.root = root
         title = "Root"
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
   
   // MARK: - Table view data source
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return list.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath)
      
      if let cell = cell as? PredefinedGraphViewCell
      {
         if let obj = list[indexPath.row] as? GraphSettings
         {
            cell.graphName.text = obj.shortName
         }
      }
      else if let cell = cell as? PredefinedGraphFolderViewCell
      {
         if let obj = list[indexPath.row] as? GraphFolder
         {
            cell.folderName.text = obj.name
         }
      }
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath)
      if ((cell as? PredefinedGraphViewCell) != nil)
      {
         if let obj = list[indexPath.row] as? GraphSettings
         {
            if let predefinedGraphVC = storyboard?.instantiateViewController(withIdentifier: "PredefinedGraphChartController")
            {
               (predefinedGraphVC as! PredefinedGraphChartController).object = obj
               navigationController?.pushViewController(predefinedGraphVC, animated: true)
            }
         }
      }
      else if ((cell as? PredefinedGraphFolderViewCell) != nil)
      {
         if let obj = list[indexPath.row] as? GraphFolder
         {
            //cell.folderName.text = obj.name
         }
      }
   }
}
