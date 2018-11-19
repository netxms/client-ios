//
//  ObjectToolsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 18/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectToolsViewController: UITableViewController {
   var objectId: Int!
   var objectTools = [ObjectTool]()
   var selectedObjectTool: ObjectTool!
   var inputFieldQuery = [String]()
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      Connection.sharedInstance?.getObjectTools(objectId: objectId, onSuccess: onGetObjectToolsSuccess)
   }
   
   func onGetObjectToolsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let json = jsonData,
         let objectTools = json["objectTools"] as? [[String : Any]]
      {
         for t in objectTools
         {
            let tool = ObjectTool(json: t)
            self.objectTools.append(tool)
         }
      }
      
      DispatchQueue.main.async
         {
            self.tableView.reloadData()
      }
   }
   
   override func didReceiveMemoryWarning()
   {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      // #warning Incomplete implementation, return the number of rows
      print(self.objectTools.count)
      return self.objectTools.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectToolsCell", for: indexPath)
      (cell as! ObjectToolsViewCell).objectToolName.text = objectTools[indexPath.row].displayName
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      selectedObjectTool = objectTools[indexPath.row]
      
      if !selectedObjectTool.inputFields.isEmpty
      {
         showInputDialog()
      }
      else
      {
         var details = [String : Any]()
         details.updateValue(selectedObjectTool.id, forKey: "id")
         Connection.sharedInstance?.executeObjectTool(objectId: self.objectId, details: [details], onSuccess: onExecuteObjectToolSuccess)
      }
   }
   
   func onExecuteObjectToolSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let uuid  = jsonData["UUID"] as? String
      {
         DispatchQueue.main.async
            {
               if let objectToolOutputVC = self.storyboard?.instantiateViewController(withIdentifier: "ObjectToolOutputViewController")
               {
                  (objectToolOutputVC as? ObjectToolOutputViewController)?.uuid = UUID(uuidString: uuid)
                  (objectToolOutputVC as? ObjectToolOutputViewController)?.objectId = self.objectId
                  (objectToolOutputVC as? ObjectToolOutputViewController)?.objectTool = self.selectedObjectTool
                  (objectToolOutputVC as? ObjectToolOutputViewController)?.inputFieldQuery = self.inputFieldQuery
                  self.navigationController?.pushViewController(objectToolOutputVC, animated: true)
               }
         }
      }
   }
   
   func showInputDialog()
   {
      //Creating UIAlertController and
      //Setting title and message for the alert dialog
      let alertController = UIAlertController(title: "Choose timeout", message: "Choose timeout for sticky acknowledge", preferredStyle: .alert)
      
      for f in selectedObjectTool.inputFields
      {
         //adding textfields to our dialog box
         alertController.addTextField { (textField) in
            textField.placeholder = f.key
            switch f.value.type
            {
            case InputFieldType.NUMBER:
               textField.keyboardType = .numberPad
               break
            case InputFieldType.PASSWORD:
               textField.keyboardType = .default
               textField.isSecureTextEntry = true
               break
            default: // Text
               textField.keyboardType = .default
            }
         }
      }
      
      //the confirm action taking the inputs
      let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
         //getting the input values from user
         if let textFields = alertController.textFields
         {
            var inputFields = [String]()
            for tF in textFields
            {
               let field = "\(tF.text ?? "");\(tF.placeholder ?? "")"
               inputFields.append(field)
            }
            self.inputFieldQuery = inputFields
            
            var tool = [String : Any]()
            tool.updateValue(self.selectedObjectTool.id, forKey: "id")
            tool.updateValue(inputFields, forKey: "inputFields")
            Connection.sharedInstance?.executeObjectTool(objectId: self.objectId, details: [tool], onSuccess: self.onExecuteObjectToolSuccess)
         }
      }
      
      //the cancel action doing nothing
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
      
      //adding the action to dialogbox
      alertController.addAction(confirmAction)
      alertController.addAction(cancelAction)
      
      //finally presenting the dialog box
      self.present(alertController, animated: true, completion: nil)
   }
}
