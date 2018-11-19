//
//  ObjectDetailsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 12/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   var object: AbstractObject!
   var alarms = [Alarm]()
   var lastValues = [DciValue]()
   var lastValuesWithActiveThresholds = [DciValue]()
   @IBOutlet weak var alarmTableView: UITableView!
   @IBOutlet weak var lastValuesTableView: UITableView!
   @IBOutlet weak var comments: UILabel!
   @IBOutlet weak var objectToolsButton: UIButton!
   
   @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
   @IBOutlet weak var lastValuesTabbleHeight: NSLayoutConstraint!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      objectToolsButton.layer.masksToBounds = false
      objectToolsButton.layer.shadowColor = UIColor.gray.cgColor
      objectToolsButton.layer.shadowOpacity = 0.3
      objectToolsButton.layer.shadowOffset = CGSize(width: -1, height: 2)
      objectToolsButton.layer.shadowRadius = CGFloat(integerLiteral: 3)
      
      objectToolsButton.layer.shadowPath = UIBezierPath(rect: objectToolsButton.bounds).cgPath
      objectToolsButton.layer.shouldRasterize = true
      objectToolsButton.layer.rasterizationScale = UIScreen.main.scale
      
      self.title = Connection.sharedInstance?.resolveObjectName(objectId: object.objectId)
      self.comments.text = object.comments
      let sortedAlarms = (Connection.sharedInstance?.getSortedAlarms())!
      var i = 0
      for alarm in sortedAlarms
      {
         if alarm.sourceObjectId == object.objectId && i < 4
         {
            self.alarms.append(alarm)
            i += 1
         }
      }
      
      //tableViewHeight.constant = 50.0 * CGFloat(self.alarms.count)
      
      Connection.sharedInstance?.getLastValues(objectId: object.objectId, onSuccess: onGetLastValuesSuccess)
   }
   
   func onGetLastValuesSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let lastValues = jsonData["lastValues"] as? [[String: Any]]
      {
         for v in lastValues
         {
            self.lastValues.append(DciValue(json: v))
         }
         if self.lastValues.count > 0
         {
            var i = 0
            for value in self.lastValues
            {
               if (value.activeThreshold != nil) && i < 4
               {
                  self.lastValuesWithActiveThresholds.append(value)
                  i += 1
               }
            }
            if self.lastValuesWithActiveThresholds.count > 0
            {
               self.lastValuesWithActiveThresholds = self.lastValuesWithActiveThresholds.sorted
               {
                  return ($0.description.lowercased()) < ($1.description.lowercased())
               }
            }
            DispatchQueue.main.async
            {
               //self.lastValuesTabbleHeight.constant = 50.0 * CGFloat(self.lastValuesWithActiveThresholds.count)
               //self.view.setNeedsUpdateConstraints()
               self.lastValuesTableView.reloadData()
            }
         }
      }
   }
   
   override func didReceiveMemoryWarning()
   {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      if tableView == self.alarmTableView
      {
         return alarms.count
      }
      else
      {
         return self.lastValuesWithActiveThresholds.count
      }
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      if tableView == self.alarmTableView
      {
         let cell: ObjectDetailsAlarmCell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailsAlarmCell", for: indexPath) as! ObjectDetailsAlarmCell
         
         cell.objectName.text = Connection.sharedInstance?.resolveObjectName(objectId: alarms[indexPath.row].sourceObjectId)
         cell.message.text = alarms[indexPath.row].message
         cell.createdOn.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: alarms[indexPath.row].creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
         
         switch alarms[indexPath.row].currentSeverity
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
      else
      {
         let cell: ObjectDetailsLastValuesCell = tableView.dequeueReusableCell(withIdentifier: "ObjectBrowserLastValuesCell", for: indexPath) as! ObjectDetailsLastValuesCell
         
         if lastValues.count > 0
         {
            cell.name.text = lastValuesWithActiveThresholds[indexPath.row].description
            cell.value.text = lastValuesWithActiveThresholds[indexPath.row].value.description
            cell.timestamp.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: lastValuesWithActiveThresholds[indexPath.row].timestamp), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
            
            if let activeThreshold = lastValuesWithActiveThresholds[indexPath.row].activeThreshold
            {
               switch activeThreshold.currentSeverity
               {
               case Severity.NORMAL:
                  cell.statusLabel.backgroundColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
               case Severity.WARNING:
                  cell.statusLabel.backgroundColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
               case Severity.MINOR:
                  cell.statusLabel.backgroundColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
               case Severity.MAJOR:
                  cell.statusLabel.backgroundColor = UIColor(red: 255, green: 128, blue: 0, alpha: 100)
               case Severity.CRITICAL:
                  cell.statusLabel.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
               case Severity.UNKNOWN:
                  cell.statusLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
               case Severity.TERMINATE:
                  cell.statusLabel.backgroundColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100)
               case Severity.RESOLVE:
                  cell.statusLabel.backgroundColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100)
               }
            }
         }
         
         return cell
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if tableView == self.alarmTableView
      {
         if let alarmDetailsVC = storyboard?.instantiateViewController(withIdentifier: "AlarmDetailsViewController")
         {
            (alarmDetailsVC as? AlarmDetailsViewController)?.alarm = self.alarms[indexPath.row]
            navigationController?.pushViewController(alarmDetailsVC, animated: true)
         }
      }
      else
      {
         if let lineChartVC = storyboard?.instantiateViewController(withIdentifier: "LineChartViewController")
         {
            //(lineChartVC as! LineChartViewController).dciValue = lastValuesWithActiveThresholds[indexPath.row]
            //(lineChartVC as! LineChartViewController).objectId = object.objectId
            navigationController?.pushViewController(lineChartVC, animated: true)
         }
      }
   }
   
   func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
   {
      if tableView == self.alarmTableView
      {
         let acknowledgeAction = UITableViewRowAction(style: .normal, title: "Acknowledge") { (rowAction, indexPath) in
            Connection.sharedInstance?.modifyAlarm(alarmId: self.alarms[indexPath.row].id, action: AlarmBrowserViewController.ACKNOWLEDGE_ALARM)
         }
         let terminateAction = UITableViewRowAction(style: .default, title: "Terminate") { (rowAction, indexPath) in
            Connection.sharedInstance?.modifyAlarm(alarmId: self.alarms[indexPath.row].id, action: AlarmBrowserViewController.TERMINATE_ALARM)
         }
         
         return [acknowledgeAction, terminateAction]
      }
      
      return [UITableViewRowAction]()
   }
   
   @IBAction func onLastValuesButtonPressed(_ sender: Any)
   {
      if let lastValuesVC = storyboard?.instantiateViewController(withIdentifier: "LastValuesViewController") as? LastValuesViewController
      {
         lastValuesVC.objectId = self.object.objectId
         navigationController?.pushViewController(lastValuesVC, animated: true)
      }
   }
   
   @IBAction func onAlarmsButtonPressed(_ sender: Any)
   {
      if let alarmBrowserVC = storyboard?.instantiateViewController(withIdentifier: "AlarmBrowserViewController") as? AlarmBrowserViewController
      {
         alarmBrowserVC.objectFilter = self.object.objectId
         navigationController?.pushViewController(alarmBrowserVC, animated: true)
      }
   }
   
   @IBAction func onObjectToolsButtonPressed(_ sender: Any)
   {
      
      if let objectToolsVC = storyboard?.instantiateViewController(withIdentifier: "ObjectToolsViewController") as? ObjectToolsViewController
      {
         objectToolsVC.objectId = self.object.objectId
         navigationController?.pushViewController(objectToolsVC, animated: true)
      }
   }
}
