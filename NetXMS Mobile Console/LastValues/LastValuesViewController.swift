//
//  LastValuesViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 27/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class LastValuesViewController: UITableViewController, UISearchBarDelegate
{
   var objectId: Int!
   var lastValues = [DciValue]()
   var filteredLastValues = [DciValue]()
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var cancelButton: UIBarButtonItem!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      setCancelButtonState(enabled: false)
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell))
      self.view.addGestureRecognizer(longPressRecognizer)
      self.title = "Last Values"
      Connection.sharedInstance?.getLastValues(objectId: objectId, onSuccess: onGetLastValuesSuccess)
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
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
               let value = DciValue(json: v as? [String : Any] ?? [:])
               if value.dcObjectType == 1 // Item
               {
                  self.lastValues.append(value)
               }
            }
         }
         if self.lastValues.count > 0
         {
            self.lastValues = self.lastValues.sorted {
               return ($0.description.lowercased()) < ($1.description.lowercased())
            }
            self.filteredLastValues.append(contentsOf: self.lastValues)
            DispatchQueue.main.async
            {
               self.tableView.reloadData()
            }
            
         }
      }
   }
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
   {
      filteredLastValues.removeAll()
      if searchText == ""
      {
         filteredLastValues.append(contentsOf: lastValues)
      }
      else
      {
         self.filteredLastValues = lastValues.filter { (value) -> Bool in
            if value.description.lowercased().range(of: searchText.lowercased()) != nil
            {
               return true
            }
            else if value.name.lowercased().range(of: searchText.lowercased()) != nil
            {
               return true
            }
            else if value.id.description.range(of: searchText.lowercased()) != nil
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
      // #warning Incomplete implementation, return the number of rows
      return filteredLastValues.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      let cell: LastValuesCell = tableView.dequeueReusableCell(withIdentifier: "LastValuesCell", for: indexPath) as! LastValuesCell
      
      cell.dciValue = filteredLastValues[indexPath.row]
      cell.dciName.text = filteredLastValues[indexPath.row].description
      cell.timestamp.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: filteredLastValues[indexPath.row].timestamp), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
      if filteredLastValues[indexPath.row].value == ""
      {
         cell.value.text = "<ERROR>"
         cell.value.textColor = UIColor.red
      }
      else
      {
         let formatter = LargeValueFormatter()
         cell.value.text = formatter.stringForValue(Double(filteredLastValues[indexPath.row].value)!, axis: nil)
         //cell.value.sizeToFit()
      }
      
      if let activeThreshold = filteredLastValues[indexPath.row].activeThreshold
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
      else
      {
         cell.statusLabel.text = ""
      }
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if let lineChartVC = storyboard?.instantiateViewController(withIdentifier: "LastValuesChartController"),
         self.tableView.isEditing == false
      {
         (lineChartVC as! LastValuesChartController).dciValues = [filteredLastValues[indexPath.row]]
         navigationController?.pushViewController(lineChartVC, animated: true)
      }
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
            self.navigationController?.setToolbarHidden(false, animated: true)
            // your code here, get the row for the indexPath or do whatever you want
         }
      }
   }
   
   @IBAction func onCancelButtonPressed(_ sender: Any)
   {
      self.tableView.setEditing(false, animated: true)
      self.navigationController?.setToolbarHidden(true, animated: true)
      setCancelButtonState(enabled: false)
   }
   
   func setCancelButtonState(enabled: Bool)
   {
      self.cancelButton.isEnabled = enabled
      if enabled == false
      {
         self.cancelButton.tintColor = UIColor.clear
      }
      else
      {
         self.cancelButton.tintColor = UIColor.red
      }
   }
   
   @IBAction func onActionPressed(_ sender: Any)
   {
      if let lineChartVC = storyboard?.instantiateViewController(withIdentifier: "LastValuesChartController")
      {
         var dciValues = [DciValue]()
         for cell in self.tableView.visibleCells
         {
            if let cell = cell as? LastValuesCell,
               cell.isSelected == true
            {
               dciValues.append(cell.dciValue)
            }
         }
         
         (lineChartVC as! LastValuesChartController).dciValues = dciValues
         navigationController?.pushViewController(lineChartVC, animated: true)
      }
      
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      self.tableView.setEditing(false, animated: true)
      self.navigationController?.setToolbarHidden(true, animated: true)
      setCancelButtonState(enabled: false)
   }
}
