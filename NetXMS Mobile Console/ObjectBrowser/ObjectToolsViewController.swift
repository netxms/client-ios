//
//  ObjectToolsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 18/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectToolsViewController: UITableViewController, UISearchBarDelegate {
   var objectId: Int!
   var root: ObjectToolFolder!
   var list = [AnyObject]()
   var inputFieldQuery = [String]()
   @IBOutlet weak var searchBar: UISearchBar!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      if self.root == nil
      {
         Connection.sharedInstance?.getObjectTools(objectId: objectId, onSuccess: onGetObjectToolsSuccess)
      }
      else
      {
         self.title = root.displayName
         list = getObjectList()
      }
      
      self.searchBar.delegate = self
      let searchBarHeight = searchBar.frame.size.height
      tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
   }
   
   func onGetObjectToolsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let json = jsonData,
         let rootData = json["root"] as? [String : Any]
      {
         self.root = ObjectToolFolder(json: rootData)
         self.title = "Object Tools"
         
         DispatchQueue.main.async
         {
            self.refresh()
         }
      }
   }
   
   func refresh()
   {
      list = getObjectList()
      self.tableView.reloadData()
   }
   
   func getObjectList() -> [AnyObject]
   {
      var objects = [AnyObject]()
      
      for f in root.subfolders
      {
         objects.append(f)
      }
      for t in root.tools
      {
         objects.append(t)
      }
      
      return objects.sorted
      {
         if let o1 = $0 as? ObjectTool,
            let o2 = $1 as? ObjectTool
         {
            return o1.displayName.lowercased() < o2.displayName.lowercased()
         }
         else if let o1 = $0 as? ObjectTool,
            let o2 = $1 as? ObjectToolFolder
         {
            return o1.displayName.lowercased() < o2.displayName.lowercased()
         }
         else if let o1 = $0 as? ObjectToolFolder,
            let o2 = $1 as? ObjectTool
         {
            return o1.displayName.lowercased() < o2.displayName.lowercased()
         }
         return false
      }
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      return self.list.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      if let obj = list[indexPath.row] as? ObjectTool,
         let toolCell = tableView.dequeueReusableCell(withIdentifier: "ObjectToolCell", for: indexPath) as? ObjectToolViewCell
      {
         toolCell.name.text = obj.displayName
         return toolCell
      }
      else if let obj = list[indexPath.row] as? ObjectToolFolder,
         let toolFolderCell = tableView.dequeueReusableCell(withIdentifier: "ObjectToolFolderCell", for: indexPath) as?
         ObjectToolFolderViewCell
      {
         toolFolderCell.name.text = obj.displayName
         return toolFolderCell
      }
      
      return UITableViewCell()
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if let tool = list[indexPath.row] as? ObjectTool
      {
         if !tool.inputFields.isEmpty
         {
            showInputDialog(tool: tool)
         }
         else if tool.type == ObjectToolType.TYPE_URL
         {
            DispatchQueue.main.async
            {
               if let objectToolURLOutputVC = self.storyboard?.instantiateViewController(withIdentifier: "ObjectToolURLOutputViewController") as? ObjectToolsURLOutputViewController
               {
                  objectToolURLOutputVC.tool = tool
                  objectToolURLOutputVC.objectId = self.objectId
                  self.navigationController?.pushViewController(objectToolURLOutputVC, animated: true)
               }
            }
         }
         else
         {
           let details: [String : Any] = ["id" : tool.id]
            Connection.sharedInstance?.executeObjectTool(objectId: self.objectId, details: details, onSuccess: onExecuteObjectToolSuccess)
         }
      }
      else if let folder = list[indexPath.row] as? ObjectToolFolder
      {
         if let objectToolsVC = storyboard?.instantiateViewController(withIdentifier: "ObjectToolsViewController") as? ObjectToolsViewController
         {
            objectToolsVC.root = folder
            navigationController?.pushViewController(objectToolsVC, animated: true)
         }
      }
   }
   
   func onExecuteObjectToolSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let uuid  = jsonData["UUID"] as? String,
         let toolId = jsonData["toolId"] as? Int
      {
         DispatchQueue.main.async
         {
            if let objectToolOutputVC = self.storyboard?.instantiateViewController(withIdentifier: "ObjectToolOutputViewController")
            {
               (objectToolOutputVC as? ObjectToolOutputViewController)?.uuid = UUID(uuidString: uuid)
               (objectToolOutputVC as? ObjectToolOutputViewController)?.objectId = self.objectId
               (objectToolOutputVC as? ObjectToolOutputViewController)?.inputFieldQuery = self.inputFieldQuery
               
               for o in self.list
               {
                  if let tool = o as? ObjectTool,
                     tool.id == toolId
                  {
                     (objectToolOutputVC as? ObjectToolOutputViewController)?.objectTool = tool
                  }
               }
               
               self.navigationController?.pushViewController(objectToolOutputVC, animated: true)
            }
         }
      }
   }
   
   func showInputDialog(tool: ObjectTool)
   {
      //Creating UIAlertController and
      //Setting title and message for the alert dialog
      let alertController = UIAlertController(title: tool.displayName, message: "Fill input fields", preferredStyle: .alert)
      
      for f in tool.inputFields
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
            
            let tool: [String : Any] = ["id": tool.id, "inputFields": inputFields]
            Connection.sharedInstance?.executeObjectTool(objectId: self.objectId, details: tool, onSuccess: self.onExecuteObjectToolSuccess)
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
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
   {
      if searchText == ""
      {
         refresh()
         return
      }
      else
      {
         self.list = getObjectList().filter
         {
            (obj) -> Bool in
            if let tool = obj as? ObjectTool
            {
               return tool.displayName.localizedCaseInsensitiveContains(searchText)
            }
            else if let folder = obj as? ObjectToolFolder
            {
               return folder.displayName.localizedCaseInsensitiveContains(searchText)
            }
            return false
         }
      }
      self.tableView.reloadData()
   }
}
