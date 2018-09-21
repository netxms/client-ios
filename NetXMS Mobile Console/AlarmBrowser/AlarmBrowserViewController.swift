//
//  AlarmBrowserViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 22/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class AlarmBrowserViewController: UITableViewController, UISearchBarDelegate
{
   static let TERMINATE_ALARM = 0
   static let ACKNOWLEDGE_ALARM = 1
   static let STICKY_ACKNOWLEDGE_ALARM = 2
   static let RESOLVE_ALARM = 3
   
   var alarms: [Alarm]!
   var filteredAlarms = [Alarm]()
   var objectFilter = -1
   @IBOutlet weak var searchBar: UISearchBar!
   
    override func viewDidLoad()
    {
      super.viewDidLoad()
      Connection.sharedInstance?.alarmBrowser = self
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
      filteredAlarms = (Connection.sharedInstance?.getSortedAlarms())!
      if objectFilter > -1
      {
         filteredAlarms = filteredAlarms.filter { $0.sourceObjectId == objectFilter }
      }
    }
   
   func refresh()
   {
      filteredAlarms = (Connection.sharedInstance?.getSortedAlarms())!
      if objectFilter > -1
      {
         filteredAlarms = filteredAlarms.filter { $0.sourceObjectId == objectFilter }
      }
      self.tableView.reloadData()
   }
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      if searchText == ""
      {
         filteredAlarms = (Connection.sharedInstance?.getSortedAlarms())!
      }
      else
      {
         self.filteredAlarms = (Connection.sharedInstance?.getSortedAlarms())!.filter { (alarm) -> Bool in
            if alarm.message.lowercased().range(of: searchText.lowercased()) != nil
            {
               return true
            }
            else if Connection.sharedInstance?.resolveObjectName(objectId: alarm.sourceObjectId).lowercased().range(of: searchText.lowercased()) != nil
            {
               return true
            }
            return false
         }
      }
      self.tableView.reloadData()
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return filteredAlarms.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmBrowserViewCell
      cell.objectName?.text = Connection.sharedInstance?.resolveObjectName(objectId: self.filteredAlarms[indexPath.row].sourceObjectId)
      cell.message?.text = self.filteredAlarms[indexPath.row].message
      cell.createdOn?.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: self.filteredAlarms[indexPath.row].creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      
      switch self.filteredAlarms[indexPath.row].currentSeverity
      {
      case Severity.NORMAL:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
      case Severity.WARNING:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
      case Severity.MINOR:
         cell.severityLabel.backgroundColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
      case Severity.MAJOR:
         cell.severityLabel.backgroundColor = UIColor(red: 255, green: 128, blue: 0, alpha: 100)
      case Severity.CRITICAL:
         cell.severityLabel.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
      case Severity.UNKNOWN:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
      case Severity.TERMINATE:
         cell.severityLabel.backgroundColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100)
      case Severity.RESOLVE:
         cell.severityLabel.backgroundColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100)
      }

      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if let alarmDetailsVC = storyboard?.instantiateViewController(withIdentifier: "AlarmDetailsViewController")
      {
         (alarmDetailsVC as? AlarmDetailsViewController)?.alarm = self.filteredAlarms[indexPath.row]
         navigationController?.pushViewController(alarmDetailsVC, animated: true)
      }
   }
   
   override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
   {
      let acknowledgeAction = UITableViewRowAction(style: .normal, title: "Acknowledge") { (rowAction, indexPath) in
         Connection.sharedInstance?.modifyAlarm(alarmId: self.filteredAlarms[indexPath.row].id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM)
      }
      let terminateAction = UITableViewRowAction(style: .default, title: "Terminate") { (rowAction, indexPath) in
         Connection.sharedInstance?.modifyAlarm(alarmId: self.filteredAlarms[indexPath.row].id, action: AlarmBrowserViewController.TERMINATE_ALARM)
      }
   
      return [acknowledgeAction, terminateAction]
   }
}
