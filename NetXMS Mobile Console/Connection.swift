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
   
   // Views
   var alarmBrowser: AlarmBrowserViewController?
   var objectBrowser: ObjectBrowserViewController?
   var predefinedGraphsBrowser: PredefinedGraphsViewController?
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
   func login(onSuccess: @escaping ([String : Any]?) -> Void, onFailure: @escaping ((Any?) -> Void))
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
      
      sendRequest(requestData: requestData, onSuccess: onSuccess, onFailure: onFailure)
   }
   
   /**
    * Attempt logout from NetXMS WebAPI
    */
   func logout(onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         logoutStarted = true
         let requestData = RequestData(url: "\(apiUrl)/sessions/\(self.session?.handle.description.lowercased() ?? "")", method: "DELETE")
         sendRequest(requestData: requestData, onSuccess: onSuccess, onFailure: nil)
      }
   }
   
   /**
    * Send HTTP request with onFailure closure
    */
   func sendRequest(requestData: RequestData, onSuccess: @escaping ([String : Any]?) -> Void, onFailure: ((Any?) -> Void)?)
   {
      var components = URLComponents(string: requestData.url)
      components?.queryItems = requestData.queryItems
      
      guard let url = components?.url
         else
      {
         return
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
      let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
      let task = session.dataTask(with: request) { data, response, error in
         if let error = error
         {
            print("[\(requestData.method) ERROR]: \(error)")
            if let onFailure = onFailure
            {
               onFailure(error.localizedDescription)
            }
            return
         }
         if let response = response as? HTTPURLResponse,
            (400...511).contains(response.statusCode)
         {
            print("[\(requestData.method) ERROR RESPONSE]: \(response)")
            if let onFailure = onFailure
            {
               onFailure(response)
            }
            return
         }
         
         if let data = data
         {
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            if let jsonData = jsonData
            {
               onSuccess(jsonData)
            }
         }
      }
      task.resume()
   }
   
   func storeCertificate(cert: SecCertificate, key: String)
   {
      var query: [String : Any] = [kSecClass as String : kSecClassCertificate,
                                   kSecValueRef as String : cert]
      
      SecItemDelete(query as CFDictionary)
      query.updateValue(kSecAttrLabel as String, forKey: key)
      let status = SecItemAdd(query as CFDictionary, nil)
      if status != errSecSuccess { print("Error cert save") }
   }
   
   func loadCertificate(key: String) -> SecCertificate?
   {
      let query: [String : Any] = [kSecClass as String : kSecClassCertificate,
                                   kSecAttrLabel as String : key,
                                   kSecReturnRef as String : kCFBooleanTrue]
      var item: CFTypeRef?
      let status = SecItemCopyMatching(query as CFDictionary, &item)
      if status != errSecSuccess { print("Error cert load") }
      
      return (item != nil ? (item as! SecCertificate) : nil)
   }
   
   func validateCertificate(localCert: SecCertificate, remoteCert: SecCertificate) -> Bool
   {
      if let remoteCertData = SecCertificateCopyData(remoteCert) as NSData?,
         let localCertData = SecCertificateCopyData(localCert) as Data?
      {
         return remoteCertData.isEqual(to: localCertData)
      }
      
      return false
   }
   
   func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
   {
      guard let serverTrust = challenge.protectionSpace.serverTrust
         else
      {
         completionHandler(.cancelAuthenticationChallenge, nil)
         return
      }
      
      var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
      SecTrustEvaluate(serverTrust, &result)
      let isServerTrusted:Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
      
      if !isServerTrusted,
         let remoteCert = SecTrustGetCertificateAtIndex(serverTrust, 0)
      {
         if let localCert: SecCertificate = loadCertificate(key: challenge.protectionSpace.host),
            validateCertificate(localCert: localCert, remoteCert: remoteCert)
         {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
         }
         
         let alertController = UIAlertController(title: "Untrusted certificate from \(challenge.protectionSpace.host) received", message: "The server is presenting an untrusted certificate, would you like to accept it?", preferredStyle: .alert)
         
         //the confirm action taking the inputs
         let confirmAction = UIAlertAction(title: "Accept", style: .default) { (_) in
            self.storeCertificate(cert: remoteCert, key: challenge.protectionSpace.host)
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
               
               self.loginView?.navigationController?.pushViewController(certificateDetailsVC, animated: true)
            }
         }
         
         //adding the action to dialogbox
         alertController.addAction(confirmAction)
         alertController.addAction(cancelAction)
         alertController.addAction(showCertificateAction)
         
         //finally presenting the dialog box
         self.loginView?.present(alertController, animated: true)
      }
      else
      {
         completionHandler(isServerTrusted ? .useCredential : .cancelAuthenticationChallenge, nil)
      }
   }

   
   /**
    * Send HTTP request without onFailure closure
    */
   func sendRequest(requestData: RequestData, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      sendRequest(requestData: requestData, onSuccess: onSuccess, onFailure: nil)
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
         sendRequest(requestData: requestData, onSuccess: onGetAllAlarmsSuccess)
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
         DispatchQueue.main.async
         {
               self.alarmBrowser?.refresh()
         }
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
         
         sendRequest(requestData: requestData, onSuccess: onModifyAlarmSuccess)
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
                  DispatchQueue.main.async
                  {
                     self.alarmBrowser?.refresh()
                  }
               }
            case NotificationCode.MULTIPLE_ALARMS_TERMINATED:
               if let data = n.object as? BulkAlarmStateChangeData
               {
                  for id in data.alarms ?? []
                  {
                     self.alarmCache.removeValue(forKey: id)
                  }
                  DispatchQueue.main.async
                  {
                     self.alarmBrowser?.refresh()
                  }
               }
            case NotificationCode.MULTIPLE_ALARMS_RESOLVED:
               if let data = n.object as? BulkAlarmStateChangeData
               {
                  for id in data.alarms ?? []
                  {
                     if let alarm = self.alarmCache[id]
                     {
                        alarm.state = Alarm.STATE_RESOLVED
                     }
                  }
                  DispatchQueue.main.async
                  {
                     self.alarmBrowser?.refresh()
                  }
               }
            case NotificationCode.OBJECT_CHANGED:
               if let object = n.object as? AbstractObject
               {
                  self.objectCache.updateValue(object, forKey: object.objectId)
                  DispatchQueue.main.async
                  {
                     self.objectBrowser?.refresh()
                  }
               }
            case NotificationCode.OBJECT_DELETED:
               self.objectCache.removeValue(forKey: n.subCode)
               DispatchQueue.main.async
               {
                  self.objectBrowser?.refresh()
               }
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
      if logoutStarted == true
      {
         return
      }
      
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/notifications", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         sendRequest(requestData: requestData, onSuccess: onReceiveNotificationSuccess, onFailure: onReceiveNotificationFailure)
      }
   }
   
   /**
    * Start handler for receiving notifications from NetXMS WebAPI
    */
   func startNotificationHandler()
   {
      sendNotificationRequest()
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
         sendRequest(requestData: requestData, onSuccess: onGetAllObjectsSuccess)
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
         DispatchQueue.main.async
         {
            self.objectBrowser?.refresh()
         }
      }
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
         
         sendRequest(requestData: requestData, onSuccess: onSuccess)
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
         sendRequest(requestData: requestData, onSuccess: onSuccess)
      }
   }
   
   func getHistoricalData(objectId: Int, dciId: Int, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/datacollection/\(dciId)/values", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         sendRequest(requestData: requestData, onSuccess: onSuccess)
      }
   }
   
   func getPredefinedGraphs()
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/predefinedgraphs", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         sendRequest(requestData: requestData, onSuccess: onGetPredefinedGraphsSuccess)
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
         sendRequest(requestData: requestData, onSuccess: onSuccess)
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
         
         sendRequest(requestData: requestData, onSuccess: onSuccess)
      }
   }
   
   func getObjectToolOutput(objectId: Int, uuid: UUID, onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/objecttools/output/\(uuid)", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         
         sendRequest(requestData: requestData, onSuccess: onSuccess)
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
         
         sendRequest(requestData: requestData, onSuccess: onStopObjectToolSuccess)
      }
   }
   
   func onStopObjectToolSuccess(jsonData: [String : Any]?) -> Void
   {
      
   }
}
