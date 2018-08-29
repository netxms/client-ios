//
//  LastValuesViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 27/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class LastValuesViewController: UITableViewController, UISearchBarDelegate {
   var objectId: Int!
   var lastValues = [DciValue]()
   var filteredLastValues = [DciValue]()
   @IBOutlet weak var searchBar: UISearchBar!
   
    override func viewDidLoad() {
        super.viewDidLoad()
      self.title = "Last Values"
      Connection.sharedInstance?.getLastValues(objectId: objectId, onSuccess: onGetLastValuesSuccess)
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLastValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: LastValuesCell = tableView.dequeueReusableCell(withIdentifier: "LastValuesCell", for: indexPath) as! LastValuesCell
      
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
         cell.value.text = filteredLastValues[indexPath.row].value//formatter.stringForValue(Double(filteredLastValues[indexPath.row].value)!, axis: nil)
      }
      
      if let activeThreshold = filteredLastValues[indexPath.row].activeThreshold
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

        return cell
    }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if let lineChartVC = storyboard?.instantiateViewController(withIdentifier: "LineChartViewController")
      {
         (lineChartVC as! LineChartViewController).dciValue = filteredLastValues[indexPath.row]
         (lineChartVC as! LineChartViewController).objectId = objectId
         navigationController?.pushViewController(lineChartVC, animated: true)
      }
   }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
