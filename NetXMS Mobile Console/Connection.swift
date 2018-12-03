//
//  Connection.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 10/01/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

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
class Connection
{
   static private let OBJECT_CHANGED = 4
   static private let OBJECT_DELETED = 99
   static private let ALARM_DELETED = 1003
   static private let NEW_ALARM = 1004
   static private let ALARM_CHANGED = 1005
   static private let ALARM_TERMINATED = 1011
   static private let MULTIPLE_ALARMS_TERMINATED = 1032;
   static private let MULTIPLE_ALARMS_RESOLVED = 1033;
   
   static var sharedInstance: Connection?
   
   var login: String
   var password: String
   var apiUrl: String
   var objectCache = [Int : AbstractObject]()
   var rootObjects = [Int : AbstractObject]()
   var alarmCache = [Int : Alarm]()
   var predefinedGraphRoot: GraphFolder?
   var timer: Timer?
   var refreshAlarmBrowser = false
   var refreshObjectBrowser = false
   var logoutStarted = false
   var session: Session?
   
   // Views
   var alarmBrowser: AlarmBrowserViewController?
   var objectBrowser: ObjectBrowserViewController?
   var predefinedGraphsBrowser: PredefinedGraphsViewController?
   
   /**
    * Connection object constructor
    */
   init(login: String, password: String, apiUrl: String)
   {
      self.login = login
      self.password = password
      self.apiUrl = apiUrl
      self.alarmBrowser = nil
      self.session = nil
   }
   
   /**
    * Attempt login to NetXMS WebAPI
    */
   func login(onSuccess: @escaping ([String : Any]?) -> Void)
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
      
      sendRequest(requestData: requestData, onSuccess: onSuccess, onFailure: onLoginFailure)
   }
   
   /**
    * Handler for failed login to NetXMS WebAPI
    */
   func onLoginFailure(data: AnyObject?)
   {
      // Show window for failed login
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
   func sendRequest(requestData: RequestData, onSuccess: @escaping ([String : Any]?) -> Void, onFailure: ((AnyObject?) -> Void)?)
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
      
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error
         {
            print("[\(requestData.method) ERROR]: \(error)")
            if let onFailure = onFailure
            {
               onFailure(nil)
            }
            return
         }
         if let response = response as? HTTPURLResponse,
            (400...511).contains(response.statusCode)
         {
            print("[\(requestData.method) ERROR RESPONSE]: \(response.statusCode)")
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
         if refreshAlarmBrowser
         {
            DispatchQueue.main.async
               {
                  self.alarmBrowser?.refresh()
            }
            refreshAlarmBrowser = false
         }
      }
   }
   
   /**
    * Modify alarm
    */
   func modifyAlarm(alarmList: [[String : Any]])
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/alarms", method: "POST")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         let json: [String : Any] = ["alarmList" : alarmList]
         requestData.requestBody = try? JSONSerialization.data(withJSONObject: json)
         
         sendRequest(requestData: requestData, onSuccess: onModifyAlarmSuccess)
      }
   }
   
   func modifyAlarm(alarmId: Int, action: Int, timeout: Int)
   {      
      var alarmList = ["alarmId" : alarmId, "action" : action]
      if (action == AlarmBrowserViewController.STICKY_ACKNOWLEDGE_ALARM)
      {
         alarmList.updateValue(timeout, forKey: "timeout")
      }
      modifyAlarm(alarmList: [alarmList])
   }
   
   func modifyAlarm(alarmId: Int, action: Int)
   {
      modifyAlarm(alarmId: alarmId, action: action, timeout: 0)
   }
   
   func onModifyAlarmSuccess(jsonData: [String : Any]?) -> Void
   {
   }
   
   func onReceiveNotificationSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let code = jsonData["code"] as? Int
      {
         switch code
         {
         case Connection.ALARM_DELETED, Connection.NEW_ALARM, Connection.ALARM_CHANGED,
              Connection.ALARM_TERMINATED, Connection.MULTIPLE_ALARMS_RESOLVED, Connection.MULTIPLE_ALARMS_TERMINATED:
            refreshAlarmBrowser = true
            getAllAlarms()
         case Connection.OBJECT_CHANGED, Connection.OBJECT_DELETED:
            refreshObjectBrowser = true
            getAllObjects()
            getRootObjects()
         default:
            break
         }
      }
      DispatchQueue.main.async
      {
         self.sendNotificationRequest()
      }
   }
   
   func onReceiveNotificationFailure(data: AnyObject?)
   {
      if let response = data as? HTTPURLResponse
      {
         switch response.statusCode
         {
         case 401: // Access Denied
            print("notification access denied")
         case 408: // Timeout
            print("Timeout, resend notification")
            sendNotificationRequest()
         default:
            print("default")
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
   
   /*@objc func refreshObjects()
    {
    var requestData = RequestData(url: "\(apiUrl)/objects", method: "GET")
    requestData.fields.updateValue(sessionDataMap["sessionId"] as! String, forKey: "Session-Id")
    sendRequest(requestData: requestData) { jsonData in
    print(jsonData)
    }
    }*/
   
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
            switch o["objectClass"] as! Int
            {
            case AbstractObject.OBJECT_NODE:
               object = Node(json: o)
               /*case AbstractObject.OBJECT_CLUSTER:
                object = Cluster(json: o)
                case AbstractObject.OBJECT_CONTAINER:
                object = Container(json: o)*/
            default:
               object = AbstractObject(json: o)
            }
            objectCache.updateValue(object, forKey: object.objectId)
         }
      }
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
    * Get root objects
    */
   func getRootObjects()
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects", method: "GET")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         requestData.queryItems.append(URLQueryItem(name: "rootObjectsOnly", value: "true"))
         
         sendRequest(requestData: requestData, onSuccess: onGetRootObjectsSuccess)
      }
   }
   
   func onGetRootObjectsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let objects = jsonData["objects"] as? [[String : Any]]
      {
         rootObjects.removeAll()
         for o in objects
         {
            var object: AbstractObject
            switch o["objectClass"] as! Int
            {
            case AbstractObject.OBJECT_NODE:
               object = Node(json: o)
               /*case AbstractObject.OBJECT_CLUSTER:
                object = Cluster(json: o)
                case AbstractObject.OBJECT_CONTAINER:
                object = Container(json: o)*/
            default:
               object = AbstractObject(json: o)
            }
            rootObjects.updateValue(object, forKey: object.objectId)
         }
         if refreshObjectBrowser
         {
            DispatchQueue.main.async
            {
               self.objectBrowser?.refresh()
            }
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
   
   func getSortedRootObjects() -> [AbstractObject]
   {
      return rootObjects.values.sorted {
         return ($0.objectName.lowercased()) < ($1.objectName.lowercased())
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
         //requestData.queryItems.append(URLQueryItem(name: "timeInterval", value: "900"))
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
   
   func executeObjectTool(objectId: Int, details: [[String : Any]], onSuccess: @escaping ([String : Any]?) -> Void)
   {
      if self.session != nil
      {
         var requestData = RequestData(url: "\(apiUrl)/objects/\(objectId)/objecttools", method: "POST")
         requestData.fields.updateValue(String(describing: self.session?.handle), forKey: "Session-Id")
         let json: [String : Any] = ["toolList" : details]
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
