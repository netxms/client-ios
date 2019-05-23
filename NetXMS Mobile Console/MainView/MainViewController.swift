//
//  MainViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 10/05/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
   static let ITEM_COUNT = 3
   @IBOutlet var tableView: UITableView!
   
   override func viewDidLoad()
   {
      self.navigationController?.setToolbarHidden(true, animated: false)
      
      self.title = "\(Connection.sharedInstance!.session!.userData.name)@\(Connection.sharedInstance!.session!.serverData.address)"
      
      self.tableView.delegate = self
      self.tableView.dataSource = self
      
      self.tableView.setContentOffset(CGPoint(x: 0, y: 20), animated: false)
      super.viewDidLoad()
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return MainViewController.ITEM_COUNT
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCell
      {
         if indexPath.row == 0
         {
            cell.name.text = "Objects"
            cell.label.image = #imageLiteral(resourceName: "ObjectBrowser.png")
         }
         else if indexPath.row == 1
         {
            cell.name.text = "Alarms"
            cell.label.image = #imageLiteral(resourceName: "AlarmBrowser.png")
         }
         else if indexPath.row == 2
         {
            cell.name.text = "Graphs"
            cell.label.image = #imageLiteral(resourceName: "PredefinedGraphs.png")
         }
         
         return cell
      }
      return UITableViewCell()
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      tableView.deselectRow(at: indexPath, animated: true)
      if indexPath.row == 0
      {
         if let objectsVC = storyboard?.instantiateViewController(withIdentifier: "ObjectBrowserViewController"),
            self.tableView.isEditing == false
         {
            navigationController?.pushViewController(objectsVC, animated: true)
         }
      }
      else if indexPath.row == 1
      {
         if let alarmsVC = storyboard?.instantiateViewController(withIdentifier: "AlarmBrowserViewController"),
            self.tableView.isEditing == false
         {
            navigationController?.pushViewController(alarmsVC, animated: true)
         }
      }
      else if indexPath.row == 2
      {
         if let graphsVC = storyboard?.instantiateViewController(withIdentifier: "PredefinedGraphsViewController"),
            self.tableView.isEditing == false
         {
            navigationController?.pushViewController(graphsVC, animated: true)
         }
      }
   }
   
   @IBAction func logoutButtonPressed(_ sender: Any)
   {
      Connection.sharedInstance?.logout(onSuccess: onLogoutSuccess)
      self.presentingViewController?.dismiss(animated: true, completion: nil)
      Connection.sharedInstance = nil
   }
   
   func onLogoutSuccess(jsonData: [String : Any]?) -> Void
   {
   }
}
