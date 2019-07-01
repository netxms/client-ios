//
//  AlarmBrowserViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 22/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

extension UIImageView
{
   func setImageColor(color: UIColor)
   {
      let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
      self.image = templateImage
      self.tintColor = color
   }
}

extension Array
{
   mutating func insert(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int
   {
      var lo = 0
      var hi = self.count - 1
      while lo <= hi
      {
         let mid = (lo + hi)/2
         if isOrderedBefore(self[mid], elem)
         {
            lo = mid + 1
         } else if isOrderedBefore(elem, self[mid])
         {
            hi = mid - 1
         } else
         {
            insert(elem, at: mid)
            return mid // found at position mid
         }
      }
      insert(elem, at: lo)
      return lo // not found, would be inserted at position lo
   }
}

class AlarmBrowserViewController: UITableViewController, UISearchBarDelegate
{
   var alarms: [Alarm]!
   var filteredAlarms = [Alarm]()
   var object: AbstractObject!
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet var cancelButton: UIBarButtonItem!
   var selectBarButtonItem: UIBarButtonItem!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      self.title = "Alarms"
      
      refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
      
      selectBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(AlarmBrowserViewController.selectButtonPressed(_:)))
      
      setToolbarButtons()
      
      setCancelButtonState(enabled: false)
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell))
      self.view.addGestureRecognizer(longPressRecognizer)
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
      
      filteredAlarms = filterAlarms()
      
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmChanged(_:)), name: .alarmsChanged, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmTerminated(_:)), name: .alarmsTerminated, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmResolved(_:)), name: .alarmsResolved, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(onAlarmsReceived), name: .alarmsReceived, object: nil)
   }
   
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
   {
      searchBar.resignFirstResponder()
   }
   
   func filterAlarms() -> [Alarm]
   {
      if let alarms = (Connection.sharedInstance?.getSortedAlarms())
      {
         var result = [Alarm]()
         if let object = object
         {
            for a in alarms
            {
               if object.objectClass == ObjectClass.OBJECT_CONTAINER && object.children.count > 0
               {
                  for c in object.children
                  {
                     if a.sourceObjectId == c
                     {
                        result.append(a)
                     }
                  }
               }
               else
               {
                  result = alarms.filter { $0.sourceObjectId == object.objectId }
               }
            }
            return result
         }
         else
         {
            return alarms
         }
      }
      
      return[]
   }
   
   @objc func onAlarmsReceived()
   {
      print("received")
      if let alarms = alarms,
         alarms.isEmpty
      {
         refresh()
      }
   }
   
   @objc func onAlarmChanged(_ notification: NSNotification)
   {
      print("changed") // Fix alarms that are removed (e.g. maintenance mode)
      if let alarm = notification.userInfo?["alarm"] as? Alarm,
         !filteredAlarms.contains(where: { (a) -> Bool in
            return a.id == alarm.id
         })
      {
         print("new")
         let position = filteredAlarms.insert(elem: alarm)
         {
            if ($0.currentSeverity.rawValue == $1.currentSeverity.rawValue),
               let name1 = Connection.sharedInstance?.resolveObjectName(objectId: $0.sourceObjectId),
               let name2 = Connection.sharedInstance?.resolveObjectName(objectId: $1.sourceObjectId)
            {
               return (name1.lowercased()) < (name2.lowercased())
            }
            else
            {
               return $0.currentSeverity.rawValue > $1.currentSeverity.rawValue
            }
         }
         tableView.beginUpdates()
         tableView.insertRows(at: [IndexPath(row: position, section: 0)], with: .fade)
         tableView.endUpdates()
      }
   }
   
   @objc func onAlarmTerminated(_ notification: NSNotification)
   {
      print("terminated")
      /*if let alarmIds = notification.userInfo?["alarmIds"] as? [Int]
      {
      }*/
   }
   
   @objc func onAlarmResolved(_ notification: NSNotification)
   {
      print("resolved")
      /*if let alarmIds = notification.userInfo?["alarmIds"] as? [Int]
      {
      }*/
   }
   
   func setToolbarButtons()
   {
      let acknowledgeImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
      UIImage(imageLiteralResourceName: "acknowledged").draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
      }
      let resolveImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
         UIImage(imageLiteralResourceName: "resolved").draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
      }
      let terminateImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
         UIImage(imageLiteralResourceName: "terminated").draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
      }
      
      let acknowledgeColor = UIColor(red: 0.341, green: 0.847, blue: 0.068, alpha: 1)
      let resolveColor = UIColor(red: 0.007, green: 0.591, blue: 0.0, alpha: 1)
      let terminateColor = UIColor.red
      
      let acknowledgeButton = UIButton.init(type: .custom)
      acknowledgeButton.addTarget(self, action: #selector(onAcknowledgePressed), for: .touchUpInside)
      let acknowledgeButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
      acknowledgeButton.frame = acknowledgeButtonView.frame
      let acknowledgeImageView = UIImageView(frame: CGRect(x: acknowledgeButtonView.frame.minX+15, y: 0, width: 30, height: 30))
      acknowledgeImageView.image = acknowledgeImage
      acknowledgeImageView.setImageColor(color: acknowledgeColor)
      let acknowledgeLabel = UILabel(frame: CGRect(x: acknowledgeButtonView.frame.minX, y: 25, width: 60, height: 20))
      acknowledgeLabel.text = "Acknowledge"
      acknowledgeLabel.adjustsFontSizeToFitWidth = true
      acknowledgeLabel.textColor = acknowledgeColor
      acknowledgeButtonView.addSubview(acknowledgeButton)
      acknowledgeButtonView.addSubview(acknowledgeImageView)
      acknowledgeButtonView.addSubview(acknowledgeLabel)
      let acknowledgeBarButton = UIBarButtonItem.init(customView: acknowledgeButtonView)
      
      let resolveButton = UIButton.init(type: .custom)
      resolveButton.addTarget(self, action: #selector(onResolvePressed), for: .touchUpInside)
      let resolveButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
      resolveButton.frame = resolveButtonView.frame
      let resolveImageView = UIImageView(frame: CGRect(x: resolveButtonView.frame.minX+15, y: 0, width: 30, height: 30))
      resolveImageView.image = resolveImage
      resolveImageView.setImageColor(color: resolveColor)
      let resolveLabel = UILabel(frame: CGRect(x: resolveButtonView.frame.minX+10, y: 25, width: 40, height: 20))
      resolveLabel.text = "Resolve"
      resolveLabel.adjustsFontSizeToFitWidth = true
      resolveLabel.textColor = resolveColor
      resolveButtonView.addSubview(resolveButton)
      resolveButtonView.addSubview(resolveImageView)
      resolveButtonView.addSubview(resolveLabel)
      let resolveBarButton = UIBarButtonItem.init(customView: resolveButtonView)
      
      let terminateButton = UIButton.init(type: .custom)
      terminateButton.addTarget(self, action: #selector(onTerminatePressed), for: .touchUpInside)
      let terminateButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
      terminateButton.frame = terminateButtonView.frame
      let terminateImageView = UIImageView(frame: CGRect(x: terminateButtonView.frame.minX+15, y: 0, width: 30, height: 30))
      terminateImageView.image = terminateImage
      terminateImageView.setImageColor(color: terminateColor)
      let terminateLabel = UILabel(frame: CGRect(x: terminateButtonView.frame.minX+5, y: 25, width: 50, height: 20))
      terminateLabel.text = "Terminate"
      terminateLabel.adjustsFontSizeToFitWidth = true
      terminateLabel.textColor = terminateColor
      terminateButtonView.addSubview(terminateButton)
      terminateButtonView.addSubview(terminateImageView)
      terminateButtonView.addSubview(terminateLabel)
      let terminateBarButton = UIBarButtonItem.init(customView: terminateButtonView)
      
      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      
      self.setToolbarItems([acknowledgeBarButton, flexibleSpace, resolveBarButton, flexibleSpace, terminateBarButton], animated: true)
   }
   
   @objc func refresh()
   {
      filteredAlarms = filterAlarms()
      self.tableView.reloadData()
      refreshControl?.endRefreshing()
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
            else if alarm.currentSeverity == Severity.resolveSeverity(severity: searchText.uppercased())
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
      if let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as? AlarmBrowserViewCell
      {
         cell.fillCell(alarm: filteredAlarms[indexPath.row])
         return cell
      }
      
      return UITableViewCell()
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
   
   override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
   {
      let acknowledge =  UIContextualAction(style: .normal, title: "Acknowledge") { action,view,completionHandler in
         Connection.sharedInstance?.modifyAlarm(alarmId: self.filteredAlarms[indexPath.row].id, action: AlarmAction.ACKNOWLEDGE)
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
      
      let terminate =  UIContextualAction(style: .normal, title: "Terminate") { action,view,completionHandler in
         Connection.sharedInstance?.modifyAlarm(alarmId: self.filteredAlarms[indexPath.row].id, action: AlarmAction.TERMINATE)
         self.filteredAlarms.remove(at: indexPath.row)
         tableView.beginUpdates()
         tableView.deleteRows(at: [indexPath], with: .left)
         tableView.endUpdates()
         tableView.setEditing(false, animated: true)
      }
      terminate.image = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)).image { _ in
         UIImage(imageLiteralResourceName: "terminated").draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
      }
      terminate.backgroundColor = UIColor.red
      
      return UISwipeActionsConfiguration(actions: [acknowledge, terminate])
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
            self.navigationController?.setToolbarHidden(false, animated: true)
            // your code here, get the row for the indexPath or do whatever you want
         }
      }
   }
   
   @IBAction func onCancelButtonPressed(_ sender: Any)
   {
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @objc func onAcknowledgePressed()
   {
      var alarms = [Int]()
      if let selectedRows = self.tableView.indexPathsForSelectedRows
      {
         for index in selectedRows
         {
            if let cell = tableView.cellForRow(at: index) as? AlarmBrowserViewCell
            {
               if cell.state == .RESOLVED
               {
                  continue
               }
               cell.setState(state: .ACKNOWLEDGED)
            }
            alarms.append(filteredAlarms[index.row].id)
         }
         Connection.sharedInstance?.modifyAlarm(alarms: alarms, action: AlarmAction.ACKNOWLEDGE)
      }
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @objc func onResolvePressed()
   {
      var alarms = [Int]()
      if let selectedRows = self.tableView.indexPathsForSelectedRows
      {
         for index in selectedRows
         {
            if let cell = tableView.cellForRow(at: index) as? AlarmBrowserViewCell
            {
               cell.setState(state: .RESOLVED)
            }
            alarms.append(filteredAlarms[index.row].id)
         }
         Connection.sharedInstance?.modifyAlarm(alarms: alarms, action: AlarmAction.RESOLVE)
      }
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   @objc func onTerminatePressed()
   {
      var alarms = [Int]()
      if let selectedRows = self.tableView.indexPathsForSelectedRows
      {
         for index in selectedRows
         {
            alarms.append(filteredAlarms[index.row].id)
            filteredAlarms.remove(at: index.row)
         }
         self.tableView.beginUpdates()
         self.tableView.deleteRows(at: self.tableView.indexPathsForSelectedRows!, with: .left)
         self.tableView.endUpdates()
         Connection.sharedInstance?.modifyAlarm(alarms: alarms, action: AlarmAction.TERMINATE)
      }
      self.tableView.setEditing(false, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      self.tableView.setEditing(false, animated: true)
      self.navigationController?.setToolbarHidden(true, animated: true)
      setCancelButtonState(enabled: false)
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
