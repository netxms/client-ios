//
//  ObjectDetailsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 12/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import MapKit

extension String{
   // calculate label size to show
   func size(for label:UILabel) -> CGSize{
      let alabel = label.clone()
      alabel.text = self
      alabel.sizeToFit()
      
      return alabel.bounds.size
   }
}

extension UILabel{
   // clone UILabel object
   func clone() -> UILabel{
      let data = NSKeyedArchiver.archivedData(withRootObject: self)
      return NSKeyedUnarchiver.unarchiveObject(with: data) as! UILabel
   }
}

class ObjectDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
   var object: AbstractObject!
   var alarms = [Alarm]()
   var lastValues = [DciValue]()
   var lastValuesWithActiveThresholds = [DciValue]()
   @IBOutlet var lastValuesTable: UITableView!
   @IBOutlet var alarmsTable: UITableView!
   @IBOutlet weak var objectToolsButton: UIButton!
   @IBOutlet var lastValuesHeight: NSLayoutConstraint!
   @IBOutlet weak var alarmsHeight: NSLayoutConstraint!
   @IBOutlet var alarmsHeader: UIView!
   @IBOutlet var alarmsShadow: UIView!
   @IBOutlet var alarmsStack: UIStackView!
   @IBOutlet var valuesHeader: UIView!
   @IBOutlet var valuesShadow: UIView!
   @IBOutlet var valuesStack: UIStackView!
   @IBOutlet var location: MKMapView!
   @IBOutlet var locationShadow: UIView!
   @IBOutlet var locationLabel: UIView!
   @IBOutlet var commentsLabel: UIView!
   @IBOutlet var comments: UILabel!
   @IBOutlet var commentsHeight: NSLayoutConstraint!
   @IBOutlet var commentsShadow: UIView!
   @IBOutlet var commentsLabelHeight: NSLayoutConstraint!
   @IBOutlet var commentsView: UIView!
   @IBOutlet var commentsViewHeight: NSLayoutConstraint!
   @IBOutlet var locationHeight: NSLayoutConstraint!
   @IBOutlet var commentsTop: NSLayoutConstraint!
   @IBOutlet var commentsBottom: NSLayoutConstraint!
   @IBOutlet var commentsTrailing: NSLayoutConstraint!
   @IBOutlet var commentsLeading: NSLayoutConstraint!
   @IBOutlet var locationLabelHeight: NSLayoutConstraint!
   @IBOutlet var commentsStackBottom: NSLayoutConstraint!
   @IBOutlet var commentsStackTop: NSLayoutConstraint!
   
   func centerMapOnLocation(location: CLLocation)
   {
      let regionRadius: CLLocationDistance = 1000
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
      let pin = MKPointAnnotation()
      pin.coordinate = location.coordinate
      self.location.setRegion(coordinateRegion, animated: true)
      self.location.addAnnotation(pin)
      let region = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance(exactly: 10000)!, CLLocationDistance(exactly: 10000)!)
      self.location.setRegion(self.location.regionThatFits(region), animated: true)
   }
   
   func roundCorners(view: UIView, corners: CACornerMask, radius: CGFloat)
   {
      view.clipsToBounds = true
      view.layer.cornerRadius = radius
      view.layer.maskedCorners = corners
   }
   
   @objc func locationTapped()
   {
      location.isScrollEnabled = true
      location.isZoomEnabled = true
   }
   
   @objc func mainTapped()
   {
      location.isScrollEnabled = false
      location.isZoomEnabled = false
   }
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      let locationTap = UITapGestureRecognizer(target: self, action: #selector(locationTapped))
      location.addGestureRecognizer(locationTap)
      
      let mainTap = UITapGestureRecognizer(target: self, action: #selector(mainTapped))
      mainTap.cancelsTouchesInView = false
      self.view.addGestureRecognizer(mainTap)
      
      let geoLocation = object.geolocation
      
      if geoLocation.longitude != 0 && geoLocation.latitude != 0
      {
         let initialLocation = CLLocation(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
         centerMapOnLocation(location: initialLocation)
         location.isScrollEnabled = false
         location.isZoomEnabled = false
      }
      else
      {
         self.locationHeight.constant = 0
         self.locationLabelHeight.constant = 0
         self.commentsStackTop.constant = 0
      }
      
      
      lastValuesTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: lastValuesTable.frame.size.width, height: 10))
      alarmsTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: alarmsTable.frame.size.width, height: 10))
      
      roundCorners(view: location, corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 4)
      roundCorners(view: locationLabel, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 4)
      locationShadow.layer.cornerRadius = 4
      locationShadow.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      locationShadow.layer.shadowOpacity = 1
      locationShadow.layer.shadowOffset = CGSize(width: 0, height: 4)
      locationShadow.layer.shadowRadius = 6
      
      roundCorners(view: comments, corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 4)
      roundCorners(view: commentsLabel, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 4)
      commentsShadow.layer.cornerRadius = 4
      commentsShadow.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      commentsShadow.layer.shadowOpacity = 1
      commentsShadow.layer.shadowOffset = CGSize(width: 0, height: 4)
      commentsShadow.layer.shadowRadius = 6
      
      roundCorners(view: alarmsTable, corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 4)
      roundCorners(view: alarmsHeader, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 4)
      alarmsShadow.layer.cornerRadius = 4
      alarmsShadow.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      alarmsShadow.layer.shadowOpacity = 1
      alarmsShadow.layer.shadowOffset = CGSize(width: 0, height: 4)
      alarmsShadow.layer.shadowRadius = 6
      
      roundCorners(view: lastValuesTable, corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 4)
      roundCorners(view: valuesHeader, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 4)
      valuesShadow.layer.cornerRadius = 4
      valuesShadow.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.15).cgColor
      valuesShadow.layer.shadowOpacity = 1
      valuesShadow.layer.shadowOffset = CGSize(width: 0, height: 4)
      valuesShadow.layer.shadowRadius = 6
      
      self.alarmsTable.delegate = self
      self.alarmsTable.dataSource = self
      self.lastValuesTable.delegate = self
      self.lastValuesTable.dataSource = self
      
      self.title = Connection.sharedInstance?.resolveObjectName(objectId: object.objectId)
      
      if !object.comments.isEmpty
      {
         let height = object.comments.size(for: self.comments).height
         self.commentsHeight.constant = height + 24
         self.commentsTop.constant = 16
         //self.commentsBottom.constant = 16
         self.commentsLeading.constant = 16
         self.commentsTrailing.constant = 16
         self.comments.text = object.comments
      }
      else
      {
         commentsLabelHeight.constant = 0
         self.commentsStackBottom.constant = 0
      }
      
      populateAlarmTable()
      
      Connection.sharedInstance?.getLastValues(objectId: object.objectId, onSuccess: onGetLastValuesSuccess)
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmChanged), name: .alarmsChanged, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmChanged), name: .alarmsTerminated, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmChanged), name: .alarmsResolved, object: nil)
   }
   
   func populateAlarmTable()
   {
      let sortedAlarms = (Connection.sharedInstance?.getSortedAlarms())!
      alarms.removeAll()
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
      
      if self.alarms.count > 0
      {
         alarmsHeight.constant = 70.0 * CGFloat(self.alarms.count)
      }
   }
   
   @objc func onAlarmChanged()
   {
      populateAlarmTable()
      self.alarmsTable.reloadData()
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
         if self.lastValuesWithActiveThresholds.count > 0
         {
            self.lastValuesHeight.constant = 70.0 * CGFloat(self.lastValuesWithActiveThresholds.count)
            self.view.updateConstraints()
            self.lastValuesTable.reloadData()
         }
      }
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      if tableView == self.alarmsTable
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
      if tableView == self.alarmsTable && self.alarms.count > 0
      {
         let cell: ObjectDetailsAlarmCell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailsAlarmCell", for: indexPath) as! ObjectDetailsAlarmCell
         cell.fillCell(alarm: alarms[indexPath.row])
         
         return cell
      }
      else if tableView == self.lastValuesTable && self.lastValuesWithActiveThresholds.count > 0
      {
         if let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailsLastValuesCell", for: indexPath) as? ObjectDetailsLastValuesCell
         {
            cell.fillCell(value: lastValuesWithActiveThresholds[indexPath.row])
            
            return cell
         }
      }
      else
      {
         let cell: ObjectDetailsNoDataCell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailsNoDataCell", for: indexPath) as! ObjectDetailsNoDataCell
         
         return cell
      }
      
      return UITableViewCell()
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if tableView == self.alarmsTable
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
      tableView.deselectRow(at: indexPath, animated: true)
   }
   
   func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
   {
      if tableView == self.alarmsTable
      {
         let acknowledge =  UIContextualAction(style: .normal, title: nil) { action,view,completionHandler in
            Connection.sharedInstance?.modifyAlarm(alarmId: self.alarms[indexPath.row].id, action: AlarmAction.ACKNOWLEDGE)
            if let cell = tableView.cellForRow(at: indexPath) as? AlarmBrowserViewCell
            {
               if cell.state != .RESOLVED
               {
                  cell.setState(state: .ACKNOWLEDGED)
               }
            }
            tableView.setEditing(false, animated: true)
         }
         acknowledge.image = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)).image { _ in
            UIImage(imageLiteralResourceName: "acknowledged").draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
         }
         acknowledge.backgroundColor = UIColor.green
         
         let terminate =  UIContextualAction(style: .normal, title: nil) { action,view,completionHandler in
            Connection.sharedInstance?.modifyAlarm(alarmId: self.alarms[indexPath.row].id, action: AlarmAction.TERMINATE)
         }
         terminate.image = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)).image { _ in
            UIImage(imageLiteralResourceName: "terminated").draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
         }
         terminate.backgroundColor = UIColor.red
         
         return UISwipeActionsConfiguration(actions: [acknowledge, terminate])
      }
      
      return UISwipeActionsConfiguration(actions: [])
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
   @IBAction func onObjectToolsPressed(_ sender: Any)
   {
      if let objectToolsVC = storyboard?.instantiateViewController(withIdentifier: "ObjectToolsViewController") as? ObjectToolsViewController
      {
         objectToolsVC.objectId = self.object.objectId
         navigationController?.pushViewController(objectToolsVC, animated: true)
      }
   }
   
   @IBAction func onLocationButtonPressed(_ sender: Any)
   {
      if let locationViewVC = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
      {
         locationViewVC.object = self.object
         navigationController?.pushViewController(locationViewVC, animated: true)
      }
   }
}
