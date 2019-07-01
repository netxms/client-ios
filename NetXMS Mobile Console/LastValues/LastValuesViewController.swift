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
      
      setToolbarButtons()
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
   }
   
   func setToolbarButtons()
   {
      let actionImage = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40)).image { _ in
         UIImage(imageLiteralResourceName: "Graph").draw(in: CGRect(x: 0, y: 0, width: 40, height: 40))
      }
      
      let actionButton = UIButton.init(type: .custom)
      actionButton.addTarget(self, action: #selector(onActionPressed), for: .touchUpInside)
      let actionButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
      actionButton.frame = actionButtonView.frame
      let actionImageView = UIImageView(frame: CGRect(x: actionButtonView.frame.minX, y: 0, width: 40, height: 40))
      actionImageView.image = actionImage
      actionImageView.setImageColor(color: UIColor.black)
      actionButtonView.addSubview(actionButton)
      actionButtonView.addSubview(actionImageView)
      let actionBarButton = UIBarButtonItem.init(customView: actionButtonView)
      
      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      self.setToolbarItems([actionBarButton, flexibleSpace], animated: true)
   }
   
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
   {
      searchBar.resignFirstResponder()
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
      if let cell = tableView.dequeueReusableCell(withIdentifier: "LastValuesCell", for: indexPath) as? LastValuesCell
      {
         cell.fillCell(value: filteredLastValues[indexPath.row])
         
         return cell
      }
      return UITableViewCell()
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if filteredLastValues[indexPath.row].value == Double(-1)
      {
         self.tableView.deselectRow(at: indexPath, animated: false)
         return
      }
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
   
   @objc func onActionPressed()
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
