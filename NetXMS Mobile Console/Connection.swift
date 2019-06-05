//
//  Connection.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 10/01/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import KeychainAccess


/**
 * Data used to create request
 */
struct RequestData
{
   let url: String
   let method: String
   var fields: [String : String]
   var requestBody: Data?
   var queryItems = [URLQueryItem]()
   
   init(url: String, method: String)
   {
      self.url = url
      self.method = method
      self.fields = [:]
   }
}

extension Notification.Name
{
   static let alarmsChanged = Notification.Name("alarmsChanged")
   static let objectChanged = Notification.Name("objectChanged")
}

/**
 * Connection handler class
 */
class Connection: NSObject, URLSessionDelegate
{
   static var sharedInstance: Connection?
   
   var login: String
   var password: String
   var apiUrl: String
   var objectCache = [Int : AbstractObject]()
   var alarmCache = [Int : Alarm]()
   var predefinedGraphRoot = GraphFolder(json: [:])
   var refreshAlarmBrowser = false
   var refreshObjectBrowser = false
   var logoutStarted = false
   var session: Session?
   var failedRequest: URLRequest?
   var handler: (([String : Any]?) -> Void)?
   var notificationWorkItem: DispatchWorkItem?
   
   // Views
   var loginView: LoginViewController?
   
   /**
    * Connection object constructor
    */
   init(login: String, password: String, apiUrl: String)
   {
      self.login = login
      self.password = password
      self.apiUrl = apiUrl
      self.session = nil
   }
   
   /**
    * Attempt login to NetXMS WebAPI
    */
   func login(onSuccess: @escaping ([String : Any]?) -> Void, onFailure: ((Any?) -> Void)? = nil)
   {
      var auth = String(format: "%@:%@", login, password)
      guard let loginData = auth.data(using: .utf8)
         else
      {
         print("Unable to encode auth data")
         return
      }
      auth = "Basic \(loginData.base64EncodedString())"
      
      var requestData = RequestData(url: "\(apiUrl)/sessions", method: "POST")
      requestData.fields.updateValue(auth, forKey: "Authorization")
      
      let json: [String : Any] = ["attachNotificationHandler" : true]
      requestData.requestBody = try? JSONSerialization.data(withJSONObject: json)
      
      if let request = createRequest(requestData: requestData)
      {
         sendRequest(request: request, onSuccess: onSuccess, onFailure: onFailure)
      }
   }
   
   func relogin(request: URLRequest, handler: @escaping ([String : Any]?) -> Void)
   {
      self.failedRequest = request
      self.handler = handler
      login(onSuccess: onReloginSuccess)
   }
   
   /**
    * Attempt logout from NetXMS WebAPI
    */
   func logout(onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         stopNotificationHandler()
         let requestData = RequestData(url: "\(apiUrl)/sessions/\(self.session?.handle.description.lowercased() ?? "")", method: "DELETE")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   func createRequest(requestData: RequestData) -> URLRequest?
   {
      var components = URLComponents(string: requestData.url)
      components?.queryItems = requestData.queryItems
      
      guard let url = components?.url
         else
      {
         return nil
      }
      
      var request = URLRequest(url: url)
      request.httpMethod = requestData.method
      if let body = requestData.requestBody
      {
         request.httpBody = body
      }
      for (key, value) in requestData.fields
      {
         request.setValue(value, forHTTPHeaderField: key)
      }
      
      return request
   }
   
   /**
    * Send HTTP request with onFailure closure
    */
   func sendRequest(request: URLRequest, onSuccess: @escaping ([String : Any]?) -> Void, onFailure: ((Any?) -> Void)? = nil)
   {
      let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
      let task = session.dataTask(with: request) { data, response, error in
         if let data = data,
            let response = response as? HTTPURLResponse
         {
            if (400...511).contains(response.statusCode)
            {
               print("[\(String(describing: request.httpMethod)) ERROR RESPONSE]: \(response)")
               if response.statusCode == 401 // Unauthorized
               {
                  self.relogin(request: request, handler: onSuccess)
               }
               else if let onFailure = onFailure
               {
                  onFailure(response)
               }
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            if let jsonData = jsonData
            {
               onSuccess(jsonData)
            }
         }
         else if let error = error
         {
            print("error: " + error.localizedDescription)
            if let onFailure = onFailure
            {
               onFailure(error.localizedDescription)
            }
         }
      }
      task.resume()
   }
   
   func onReloginSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let request = failedRequest,
         let handler = handler
      {
         session = Session(json: jsonData)
         sendRequest(request: request, onSuccess: handler)
         getAllObjects()
         getAllAlarms()
         getPredefinedGraphs()
         if notificationWorkItem?.isCancelled ?? false
         {
            startNotificationHandler()
         }
      }
   }
   
   func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
   {
      guard let serverTrust = challenge.protectionSpace.serverTrust
         else
      {
         completionHandler(.cancelAuthenticationChallenge, nil)
         return
      }
      
      var result: SecTrustResultType = SecTrustResultType.invalid
      SecTrustEvaluate(serverTrust, &result)
      let isServerTrusted:Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
      
      if !isServerTrusted,
         let remoteCert = SecTrustGetCertificateAtIndex(serverTrust, 0),
         let remoteCertData = SecCertificateCopyData(remoteCert) as Data?
      {
         if let localCertData = try? AppDelegate.keychain.getData(apiUrl),
            localCertData == remoteCertData
         {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
         }
         
         let alertController = UIAlertController(title: "Untrusted certificate from \(challenge.protectionSpace.host) received", message: "The server is presenting an untrusted certificate, would you like to accept it?", preferredStyle: .alert)
         
         //the confirm action taking the inputs
         let confirmAction = UIAlertAction(title: "Accept", style: .default) { (_) in
            try? AppDelegate.keychain.set(remoteCertData, key: self.apiUrl)
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
         }
         
         //the cancel action doing nothing
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completionHandler(.cancelAuthenticationChallenge, nil)
         }
         
         let showCertificateAction = UIAlertAction(title: "Show certificate", style: .default) { (_) in
            if self.loginView != nil,
               let certificateDetailsVC = self.loginView?.storyboard?.instantiateViewController(withIdentifier: "CertificateDetailsView") as? CertificateDetailsViewController,
               let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
               let subject = SecCertificateCopySubjectSummary(certificate),
               let key = SecCertificateCopyKey(certificate).debugDescription as String?
            {
               certificateDetailsVC.subject = subject as String
               certificateDetailsVC.pubKey = key
               certificateDetailsVC.completionHandler = completionHandler
               certificateDetailsVC.trust = serverTrust
               certificateDetailsVC.certData = remoteCertData
               self.loginView?.alert.dismiss(animated: true, completion: nil)
               self.loginView?.navigationController?.present(certificateDetailsVC, animated: true)
            }
         }
         
         //adding the action to dialogbox
         alertController.addAction(confirmAction)
         alertController.addAction(cancelAction)
         alertController.addAction(showCertificateAction)
         
         //finally presenting the dialog box
         //self.loginView?.alert = alertController
         self.loginView?.alert.present(alertController, animated: true)
      }
      else
      {
         completionHandler(isServerTrusted ? .useCredential : .cancelAuthenticationChallenge, nil)
      }
   }
   
   /**
    * Get list of all active alarms from NetXMS WebAPI
    */
   func getAllAlarms()
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/alarms", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onGetAllAlarmsSuccess)
         }
      }
   }
   
   func onGetAllAlarmsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let alarms = jsonData["alarms"] as? [[String: Any]]
      {
         alarmCache.removeAll()
         for a in alarms
         {
            let alarm = Alarm(json: a)
            alarmCache.updateValue(alarm, forKey: alarm.id)
         }
         NotificationCenter.default.post(name: .alarmsChanged, object: nil)
      }
   }
   
   /**
    * Modify alarm
    */
   func modifyAlarm(alarms: [Int], action: AlarmAction, timeout: Int)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/alarms", method: "POST")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         requestData.queryItems.append(URLQueryItem(name: "command", value: action.rawValue))
         var json: [String : Any] = ["alarms" : alarms]
         if timeout > 0
         {
            json.updateValue(timeout, forKey: "timeout")
         }
         requestData.requestBody = try? JSONSerialization.data(withJSONObject: json)
         
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onModifyAlarmSuccess)
         }
      }
   }
   
   func modifyAlarm(alarms: [Int], action: AlarmAction)
   {
      modifyAlarm(alarms: alarms, action: action, timeout: 0)
   }
   
   func modifyAlarm(alarmId: Int, action: AlarmAction)
   {
      modifyAlarm(alarms: [alarmId], action: action, timeout: 0)
   }
   
   func modifyAlarm(alarmId: Int, action: AlarmAction, timeout: Int)
   {
      modifyAlarm(alarms: [alarmId], action: action, timeout: timeout)
   }
   
   func onModifyAlarmSuccess(jsonData: [String : Any]?) -> Void
   {
   }
   
   func onReceiveNotificationSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
      let notifications = jsonData["notifications"] as? [[String : Any]]
      {
         for n in notifications
         {
            let n = SessionNotification(json: n)
            switch n.code!
            {
            case NotificationCode.NEW_ALARM, NotificationCode.ALARM_CHANGED:
               if let alarm = n.object as? Alarm
               {
                  self.alarmCache.updateValue(alarm, forKey: alarm.id)
                  NotificationCenter.default.post(name: .alarmsChanged, object: nil)
               }
            case NotificationCode.MULTIPLE_ALARMS_TERMINATED:
               if let data = n.object as? BulkAlarmStateChangeData
               {
                  for id in data.alarms ?? []
                  {
                     self.alarmCache.removeValue(forKey: id)
                  }
                  NotificationCenter.default.post(name: .alarmsChanged, object: nil)
               }
            case NotificationCode.MULTIPLE_ALARMS_RESOLVED:
               if let data = n.object as? BulkAlarmStateChangeData
               {
                  for id in data.alarms ?? []
                  {
                     if let alarm = self.alarmCache[id]
                     {
                        alarm.state = State.RESOLVED
                     }
                  }
                  NotificationCenter.default.post(name: .alarmsChanged, object: nil)
               }
            case NotificationCode.OBJECT_CHANGED:
               if let object = n.object as? AbstractObject
               {
                  self.objectCache.updateValue(object, forKey: object.objectId)
                  NotificationCenter.default.post(name: .objectChanged, object: nil)
               }
            case NotificationCode.OBJECT_DELETED:
               self.objectCache.removeValue(forKey: n.subCode)
               NotificationCenter.default.post(name: .objectChanged, object: nil)
            default:
               break
            }
         }
      }
      DispatchQueue.main.async
      {
         self.sendNotificationRequest()
      }
   }
   
   func onReceiveNotificationFailure(data: Any?)
   {
      if let response = data as? HTTPURLResponse
      {
         if response.statusCode == 408
         {
            sendNotificationRequest()
         }
      }
   }
   
   func sendNotificationRequest()
   {
      print("send")
      if logoutStarted == true
      {
         return
      }
      
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/notifications", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onReceiveNotificationSuccess, onFailure: onReceiveNotificationFailure)
         }
      }
   }
   
   func stopNotificationHandler()
   {
      notificationWorkItem?.cancel()
   }
   
   /**
    * Start handler for receiving notifications from NetXMS WebAPI
    */
   func startNotificationHandler()
   {
      notificationWorkItem = DispatchWorkItem {
         self.sendNotificationRequest()
      }
      
      let queue = DispatchQueue(label: "NotificationThread", qos: .background)
      queue.async(execute: notificationWorkItem!)
   }
   
   /**
    * Fill local object list
    */
   func getAllObjects()
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onGetAllObjectsSuccess)
         }
      }
   }
   
   func onGetAllObjectsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let objects = jsonData["objects"] as? [[String: Any]]
      {
         objectCache.removeAll()
         for o in objects
         {
            var object: AbstractObject
            switch ObjectClass.resolveObjectClass(objectClass: o["objectClass"] as? Int ?? 0)
            {
            case ObjectClass.OBJECT_NODE:
               object = Node(json: o)
            case ObjectClass.OBJECT_CLUSTER:
               object = Cluster(json: o)
            default:
               object = AbstractObject(json: o)
            }
            objectCache.updateValue(object, forKey: object.objectId)
         }
         NotificationCenter.default.post(name: .objectChanged, object: nil)
      }
   }
   
   func getTopLevelObjects() -> [AbstractObject]
   {
      if let serviceRoot = objectCache[2]
      {
         return Array(objectCache.filter { serviceRoot.children.contains($0.value.objectId) }.values)
      }
      return []
   }
   
   func getFilteredObjects(filter: [ObjectClass]) -> [AbstractObject]
   {
      return Array(objectCache.filter { filter.contains($0.value.objectClass) }.values)
   }
   
   func getHistoricalDataForMultipleObjects(query: String, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/datacollection/values", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         requestData.queryItems.append(URLQueryItem(name: "dciList", value: query))
         
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   /**
    * Resolve object name by Id
    */
   func resolveObjectName(objectId: Int) -> String
   {
      if let object = objectCache[objectId]
      {
         return object.objectName
      }
      else
      {
         return ""
      }
   }
   
   func getSortedAlarms() -> [Alarm]
   {
      return alarmCache.values.sorted {
         if ($0.currentSeverity.rawValue == $1.currentSeverity.rawValue)
         {
            return (resolveObjectName(objectId: $0.sourceObjectId).lowercased()) < (resolveObjectName(objectId: $1.sourceObjectId).lowercased())
         }
         else
         {
            return $0.currentSeverity.rawValue > $1.currentSeverity.rawValue
         }
      }
   }
   
   func getLastValues(objectId: Int, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/lastvalues", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   func getHistoricalData(objectId: Int, dciId: Int, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/datacollection/\(dciId)/values", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   func getPredefinedGraphs()
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/predefinedgraphs", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onGetPredefinedGraphsSuccess)
         }
      }
      
   }
   
   func onGetPredefinedGraphsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let rootData = jsonData["root"] as? [String: Any]
      {
         self.predefinedGraphRoot = GraphFolder(json: rootData)
      }

   }
   
   func getObjectTools(objectId: Int, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/objecttools", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   func executeObjectTool(objectId: Int, details: [String : Any], onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/objecttools", method: "POST")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         let json: [String : Any] = ["toolData" : details]
         requestData.requestBody = try? JSONSerialization.data(withJSONObject: json)
         
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   func getObjectToolOutput(objectId: Int, uuid: UUID, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/objecttools/output/\(uuid)", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onSuccess)
         }
      }
   }
   
   func stopObjectTool(objectId: Int, uuid: UUID, streamId: Int)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/objecttools/output/\(uuid)", method: "POST")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         let json: [String : Any] = ["streamId" : streamId, "uuid" : uuid.uuidString]
         requestData.requestBody = try? JSONSerialization.data(withJSONObject: json)
         
         if let request = createRequest(requestData: requestData)
         {
            sendRequest(request: request, onSuccess: onStopObjectToolSuccess)
         }
      }
   }
   
   func onStopObjectToolSuccess(jsonData: [String : Any]?) -> Void
   {
      
   }
}
