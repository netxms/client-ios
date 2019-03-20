//
//  ObjectDetailsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 12/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import MapKit

class ObjectDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   var object: AbstractObject!
   var alarms = [Alarm]()
   var lastValues = [DciValue]()
   var lastValuesWithActiveThresholds = [DciValue]()
   @IBOutlet weak var alarmTableView: UITableView!
   @IBOutlet weak var lastValuesTableView: UITableView!
   @IBOutlet weak var comments: UILabel!
   @IBOutlet weak var objectToolsButton: UIButton!
   @IBOutlet weak var location: MKMapView!
   @IBOutlet weak var locationShadow: UIView!
   @IBOutlet weak var lastValuesHeight: NSLayoutConstraint!
   @IBOutlet weak var alarmsHeight: NSLayoutConstraint!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      location.layer.cornerRadius = 4
      locationShadow.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      locationShadow.layer.shadowOpacity = 1
      locationShadow.layer.shadowOffset = CGSize(width: 0, height: 4)
      locationShadow.layer.shadowRadius = 6
      
      comments.layer.cornerRadius = 4
      comments.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      comments.layer.shadowOpacity = 1
      comments.layer.shadowOffset = CGSize(width: 0, height: 4)
      comments.layer.shadowRadius = 6
      
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
         else if object.children.count > 0
         {
            for child in object.children
            {
               if alarm.sourceObjectId == child && i < 4
               {
                  self.alarms.append(alarm)
                  i += 1
               }
            }
         }
      }
      
      alarmsHeight.constant = (self.alarms.count > 0 ? 70.0 * CGFloat(self.alarms.count) : 70.0)
      
      Connection.sharedInstance?.getLastValues(objectId: object.objectId, onSuccess: onGetLastValuesSuccess)
   }
   
   func onGetLastValuesSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let lastValuesLists = jsonData["lastValues"] as? [[Any]]
      {
         for list in lastValuesLists
         {
            for v in list
            {
               self.lastValues.append(DciValue(json: v as? [String : Any] ?? [:]))
            }
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
         }
      }
      
      DispatchQueue.main.async
      {
         print(self.lastValuesWithActiveThresholds.count)
         self.lastValuesHeight.constant = (self.lastValuesWithActiveThresholds.count > 0 ? 70.0 * CGFloat(self.lastValuesWithActiveThresholds.count) : 70.0)
         print(self.lastValuesHeight.constant)
         self.view.updateConstraints()
         
         if self.lastValuesWithActiveThresholds.count > 0
         {
            self.lastValuesTableView.reloadData()
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
         return (alarms.count > 0 ? alarms.count : 1)
      }
      else
      {
         return (self.lastValuesWithActiveThresholds.count > 0 ? self.lastValuesWithActiveThresholds.count : 1)
      }
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      if tableView == self.alarmTableView && self.alarms.count > 0
      {
         let cell: ObjectDetailsAlarmCell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailsAlarmCell", for: indexPath) as! ObjectDetailsAlarmCell
         
         cell.objectName.text = Connection.sharedInstance?.resolveObjectName(objectId: alarms[indexPath.row].sourceObjectId)
         cell.message.text = alarms[indexPath.row].message
         cell.createdOn.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: alarms[indexPath.row].creationTime), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
         
         switch alarms[indexPath.row].currentSeverity
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
      else if tableView == self.lastValuesTableView && self.lastValuesWithActiveThresholds.count > 0
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
                  cell.statusLabel.text = "Normal"
                  cell.statusLabel.textColor = UIColor(red: 0, green: 192, blue: 0, alpha: 100)
               case Severity.WARNING:
                  cell.statusLabel.text = "Warning"
                  cell.statusLabel.textColor = UIColor(red: 0, green: 255, blue: 255, alpha: 100)
               case Severity.MINOR:
                  cell.statusLabel.text = "Minor"
                  cell.statusLabel.textColor = UIColor(red: 231, green: 226, blue: 0, alpha: 100)
               case Severity.MAJOR:
                  cell.statusLabel.text = "Major"
                  cell.statusLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 100)
               case Severity.CRITICAL:
                  cell.statusLabel.text = "Critical"
                  cell.statusLabel.textColor = UIColor(red: 192, green: 0, blue: 0, alpha: 100)
               case Severity.UNKNOWN:
                  cell.statusLabel.text = "Unknown"
                  cell.statusLabel.textColor = UIColor(red: 0, green: 0, blue: 128, alpha: 100)
               case Severity.TERMINATE:
                  cell.statusLabel.text = "Terminate"
                  cell.statusLabel.textColor = UIColor(red: 139, green: 0, blue: 0, alpha: 100)
               case Severity.RESOLVE:
                  cell.statusLabel.text = "Resolve"
                  cell.statusLabel.textColor = UIColor(red: 0, green: 128, blue: 0, alpha: 100)
               }
            }
         }
         
         return cell
      }
      else
      {
         let cell: ObjectDetailsNoDataCell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailsNoDataCell", for: indexPath) as! ObjectDetailsNoDataCell
         
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
         if let lineChartVC = storyboard?.instantiateViewController(withIdentifier: "LastValuesChartController")
         {
            (lineChartVC as! LastValuesChartController).dciValues = [lastValuesWithActiveThresholds[indexPath.row]]
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
         alarmBrowserVC.object = self.object
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
