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
   var object: AbstractObject!
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var cancelButton: UIBarButtonItem!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      setCancelButtonState(enabled: false)
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell))
      self.view.addGestureRecognizer(longPressRecognizer)
      
      Connection.sharedInstance?.alarmBrowser = self
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
      alarms = (Connection.sharedInstance?.getSortedAlarms())!
      if object != nil
      {
         for a in alarms
         {
            if object.children.count > 0 && object.objectClass == AbstractObject.OBJECT_CONTAINER
            {
               for c in object.children
               {
                  if a.sourceObjectId == c
                  {
                     filteredAlarms.append(a)
                  }
               }
            }
            else
            {
               filteredAlarms = alarms.filter { $0.sourceObjectId == object.objectId }
            }
         }
      }
      else
      {
         filteredAlarms = alarms
      }
   }
   
   func refresh()
   {
      alarms = (Connection.sharedInstance?.getSortedAlarms())!
      if object != nil
      {
         for a in alarms
         {
            if object.children.count > 0 && object.objectClass == AbstractObject.OBJECT_CONTAINER
            {
               for c in object.children
               {
                  if a.sourceObjectId == c
                  {
                     filteredAlarms.append(a)
                  }
               }
            }
            else
            {
               filteredAlarms = alarms.filter { $0.sourceObjectId == object.objectId }
            }
         }
      }
      else
      {
         filteredAlarms = alarms
      }
      self.tableView.reloadData()
   }
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
   {
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
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return filteredAlarms.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmBrowserViewCell
      cell.alarmId = self.filteredAlarms[indexPath.row].id
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
         cell.severityLabel.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100)
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
      if let alarmDetailsVC = storyboard?.instantiateViewController(withIdentifier: "AlarmDetailsViewController"),
         self.tableView.isEditing == false
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
   
   @objc func longPressOnCell(longPressGestureRecognizer: UILongPressGestureRecognizer)
   {
      if longPressGestureRecognizer.state == UIGestureRecognizerState.began
      {
         let touchPoint = longPressGestureRecognizer.location(in: self.view)
         if let indexPath = tableView.indexPathForRow(at: touchPoint)
         {
            self.tableView.setEditing(true, animated: true)
            setCancelButtonState(enabled: true)
            // your code here, get the row for the indexPath or do whatever you want
         }
      }
   }
   
   @IBAction func onCancelButtonPressed(_ sender: Any)
   {
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @IBAction func onAcknowledgePRessed(_ sender: Any)
   {
      var alarmList = [[String : Int]]()
      for cell in self.tableView.visibleCells
      {
         if let cell = cell as? AlarmBrowserViewCell,
            cell.isSelected == true
         {
            let details = ["alarmId" : cell.alarmId, "action" : AlarmBrowserViewController.ACKNOWLEDGE_ALARM]
            alarmList.append(details as! [String : Int])
         }
      }
      Connection.sharedInstance?.modifyAlarm(alarmList: alarmList)
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @IBAction func onResolvePressed(_ sender: Any)
   {
      var alarmList = [[String : Int]]()
      for cell in self.tableView.visibleCells
      {
         if let cell = cell as? AlarmBrowserViewCell,
            cell.isSelected == true
         {
            let details = ["alarmId" : cell.alarmId, "action" : AlarmBrowserViewController.RESOLVE_ALARM]
            alarmList.append(details as! [String : Int])
         }
      }
      Connection.sharedInstance?.modifyAlarm(alarmList: alarmList)
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @IBAction func onTerminatePressed(_ sender: Any)
   {
      var alarmList = [[String : Int]]()
      for cell in self.tableView.visibleCells
      {
         if let cell = cell as? AlarmBrowserViewCell,
            cell.isSelected == true
         {
            let details = ["alarmId" : cell.alarmId, "action" : AlarmBrowserViewController.TERMINATE_ALARM]
            alarmList.append(details as! [String : Int])
         }
      }
      Connection.sharedInstance?.modifyAlarm(alarmList: alarmList)
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      self.navigationController?.setToolbarHidden(true, animated: true)
   }
   
   func setCancelButtonState(enabled: Bool)
   {
      self.cancelButton.isEnabled = enabled
      self.navigationController?.setToolbarHidden(!enabled, animated: true)
      if enabled == false
      {
         self.cancelButton.tintColor = UIColor.clear
      }
      else
      {
         self.cancelButton.tintColor = UIColor.red
      }
   }
}
