//
//  ObjectToolOutputViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 23/10/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit

class ObjectToolOutputViewController: UIViewController
{
   @IBOutlet var statusView: UIView!
   @IBOutlet var statusLabel: UILabel!
   @IBOutlet weak var textArea: UITextView!
   var uuid: UUID!
   var objectId: Int!
   var objectTool: ObjectTool!
   var inputFieldQuery = [String]()
   var streamId: Int!
   var stopBarButton: UIBarButtonItem!
   
   override func viewDidLoad()
   {
      self.navigationController?.setToolbarHidden(false, animated: false)
      super.viewDidLoad()
      
      self.title = objectTool.displayName
      
      setBarButtons()
      
      Connection.sharedInstance?.getObjectToolOutput(objectId: objectId, uuid: uuid, onSuccess: onReceiveOutputSuccess)
   }
   
   func onReceiveOutputSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let message  = jsonData["message"] as? String,
         let streamId = jsonData["streamId"] as? Int,
         let completed = jsonData["completed"] as? Bool
      {
         self.streamId = streamId
         DispatchQueue.main.async
            {
               self.textArea.text.append(contentsOf: message)
               let range = NSMakeRange(self.textArea.text.count - 1, 1)
               self.textArea.scrollRangeToVisible(range)
         }
         if !completed
         {
            Connection.sharedInstance?.getObjectToolOutput(objectId: objectId, uuid: uuid, onSuccess: onReceiveOutputSuccess)
         }
         else
         {
            statusView.backgroundColor = UIColor.red
            statusLabel.text = "Stopped"
            stopBarButton.isEnabled = false
         }
      }
   }
   
   func setBarButtons()
   {
      stopBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(onStopButtonPressed))
      stopBarButton.tintColor = UIColor.red
      self.navigationItem.rightBarButtonItem = stopBarButton
      
      let refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onRefreshPressed))
      refreshBarButton.tintColor = UIColor.blue
      
      self.setToolbarItems([refreshBarButton], animated: true)
   }
   
   @objc func onStopButtonPressed()
   {
      Connection.sharedInstance?.stopObjectTool(objectId: objectId, uuid: uuid, streamId: streamId)
      
      statusView.backgroundColor = UIColor.red
      statusLabel.text = "Stopped"
      stopBarButton.isEnabled = false
   }
   
   @objc func onRefreshPressed()
   {
      Connection.sharedInstance?.stopObjectTool(objectId: objectId, uuid: uuid, streamId: streamId)
      
    let details: [String : Any] = ["id": objectTool.id, "inputFields": inputFieldQuery]
      Connection.sharedInstance?.executeObjectTool(objectId: self.objectId, details: details, onSuccess: self.onRefreshObjectToolSuccess)
   }
   
   func onRefreshObjectToolSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let uuid  = jsonData["UUID"] as? String
      {
         DispatchQueue.main.async
         {
            self.statusView.backgroundColor = UIColor.green
            self.statusLabel.text = "Running"
            self.stopBarButton.isEnabled = true
            self.uuid = UUID(uuidString: uuid)
            self.textArea.text = ""
            Connection.sharedInstance?.getObjectToolOutput(objectId: self.objectId, uuid: self.uuid, onSuccess: self.onReceiveOutputSuccess)
         }
      }
   }
   
   @IBAction func onPinch(_ sender: UIPinchGestureRecognizer)
   {
      textArea.font = UIFont(name: textArea.font?.fontName ?? "Courier", size: 11 + sender.scale)
   }
   
   override func viewDidDisappear(_ animated: Bool)
   {
      Connection.sharedInstance?.stopObjectTool(objectId: objectId, uuid: uuid, streamId: streamId)
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      self.navigationController?.setToolbarHidden(true, animated: false)
   }
}
