//
//  AlarmBrowserViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 22/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class AlarmBrowserViewController: UITableViewController, UISearchResultsUpdating
{
   var alarms = [Alarm]()
   var searchController: UISearchController!
   var resultsController = UITableViewCo
   
    override func viewDidLoad()
    {
      super.viewDidLoad()
      
      self.searchController = UISearchController(searchResultsController: self)
      self.tableView.tableHeaderView = self.searchController.searchBar
      self.searchController.searchResultsUpdater = self

         // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
   
   func updateSearchResults(for searchController: UISearchController)
   {
      /*self.alarms = Connection.sharedInstance?.alarmCache.values.filter { (alarm) -> Bool in
         let filterString = self.searchController.searchBar.text
         
         if (alarm.message.contains(filterString))
         {
            return true
         }
         else if (alarm.)
      }*/
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if let alarmDetailsVC = storyboard?.instantiateViewController(withIdentifier: "AlarmDetailsViewController")
      {
         navigationController?.pushViewController(alarmDetailsVC, animated: true)
      }
   }
   
   override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
   {
      let acknowledgeAction = UITableViewRowAction(style: .normal, title: "Acknowledge", handler: acknowledgeAlarm)
      let terminateAction = UITableViewRowAction(style: .default, title: "Terminate", handler: terminateAlarm)
   
      return [acknowledgeAction, terminateAction]
   }
   
   func terminateAlarm(_: UITableViewRowAction, _: IndexPath) -> Void
   {
   }
   
   func acknowledgeAlarm(_: UITableViewRowAction, _: IndexPath) -> Void
   {
   }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmBrowserViewCell
      cell.objectName?.text = Connection.sharedInstance?.resolveObjectName(objectId: alarms[indexPath.row].sourceObjectId)
      cell.message?.text = alarms[indexPath.row].message
      cell.createdOn?.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: alarms[indexPath.row].creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      
      return cell
    }
}
