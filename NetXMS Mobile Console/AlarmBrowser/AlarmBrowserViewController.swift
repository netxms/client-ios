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
   var alarms: [Alarm]!
   var filteredAlarms = [Alarm]()
   var object: AbstractObject!
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet var cancelButton: UIBarButtonItem!
   var selectButton: UIButton!
   var selectBarButtonItem: UIBarButtonItem!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      selectButton = UIButton(type: .system)
      selectBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(AlarmBrowserViewController.selectButtonPressed(_:)))
      
      setCancelButtonState(enabled: false)
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell))
      self.view.addGestureRecognizer(longPressRecognizer)
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
      alarms = (Connection.sharedInstance?.getSortedAlarms())!
      if object != nil
      {
         for a in alarms
         {
            if object.children.count > 0 && object.objectClass == ObjectClass.OBJECT_CONTAINER
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
      
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmChanged), name: .alarmsChanged, object: nil)
   }
   
   @objc func onAlarmChanged()
   {
      refresh()
   }
   
   func refresh()
   {
      alarms = (Connection.sharedInstance?.getSortedAlarms())!
      if object != nil
      {
         for a in alarms
         {
            if object.children.count > 0 && object.objectClass == ObjectClass.OBJECT_CONTAINER
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
           cell.severityLabel.text = "Normal"
           cell.severityLabel.textColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
         case Severity.WARNING:
           cell.severityLabel.text = "Warning"
            cell.severityLabel.textColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
         case Severity.MINOR:
           cell.severityLabel.text = "Minor"
            cell.severityLabel.textColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
         case Severity.MAJOR:
           cell.severityLabel.text = "Major"
            cell.severityLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100)
         case Severity.CRITICAL:
           cell.severityLabel.text = "Critical"
            cell.severityLabel.textColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
         case Severity.UNKNOWN:
           cell.severityLabel.text = "Unknown"
            cell.severityLabel.textColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
         case Severity.TERMINATE:
           cell.severityLabel.text = "Terminate"
            cell.severityLabel.textColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100)
         case Severity.RESOLVE:
           cell.severityLabel.text = "Resolve"
            cell.severityLabel.textColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100)
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
         Connection.sharedInstance?.modifyAlarm(alarmId: self.filteredAlarms[indexPath.row].id, action: AlarmAction.ACKNOWLEDGE)
      }
      let terminateAction = UITableViewRowAction(style: .default, title: "Terminate") { (rowAction, indexPath) in
         Connection.sharedInstance?.modifyAlarm(alarmId: self.filteredAlarms[indexPath.row].id, action: AlarmAction.TERMINATE)
      }
      
      return [acknowledgeAction, terminateAction]
   }
   
   @objc func longPressOnCell(longPressGestureRecognizer: UILongPressGestureRecognizer)
   {
      if longPressGestureRecognizer.state == UIGestureRecognizerState.began
      {
         let touchPoint = longPressGestureRecognizer.location(in: self.view)
         if tableView.indexPathForRow(at: touchPoint) != nil
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
      var alarms = [Int]()
      for cell in self.tableView.visibleCells
      {
         if let cell = cell as? AlarmBrowserViewCell,
            cell.isSelected == true
         {
            alarms.append(cell.alarmId)
         }
      }
      Connection.sharedInstance?.modifyAlarm(alarms: alarms, action: AlarmAction.ACKNOWLEDGE)
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @IBAction func onResolvePressed(_ sender: Any)
   {
      var alarms = [Int]()
      for cell in self.tableView.visibleCells
      {
         if let cell = cell as? AlarmBrowserViewCell,
            cell.isSelected == true
         {
            alarms.append(cell.alarmId)
         }
      }
      Connection.sharedInstance?.modifyAlarm(alarms: alarms, action: AlarmAction.RESOLVE)
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @IBAction func onTerminatePressed(_ sender: Any)
   {
      var alarms = [Int]()
      for cell in self.tableView.visibleCells
      {
         if let cell = cell as? AlarmBrowserViewCell,
            cell.isSelected == true
         {
            alarms.append(cell.alarmId)
         }
      }
      Connection.sharedInstance?.modifyAlarm(alarms: alarms, action: AlarmAction.TERMINATE)
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      self.navigationController?.setToolbarHidden(true, animated: true)
   }
   
   func setCancelButtonState(enabled: Bool)
   {
      self.navigationController?.setToolbarHidden(!enabled, animated: true)
      if enabled == false
      {
         self.navigationItem.rightBarButtonItem = self.selectBarButtonItem
      }
      else
      {
         self.navigationItem.rightBarButtonItem = self.cancelButton
      }
   }
   
   @IBAction func selectButtonPressed(_ sender: Any)
   {
      self.tableView.setEditing(true, animated: true)
      setCancelButtonState(enabled: true)
   }
}
