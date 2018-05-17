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
   static var sharedInstance: Connection?
   
   var login: String
   var password: String
   var apiUrl: String
   var sessionDataMap = [String : Any]()
   var objectCache = [Int : AbstractObject]()
   var alarmCache = [Int : Alarm]()
   var timer: Timer?
   
   /**
    * Connection object constructor
    */
   init(login: String, password: String, apiUrl: String)
   {
      self.login = login
      self.password = password
      self.apiUrl = apiUrl
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
      if let sessionId = sessionDataMap["sessionId"]
      {
         let requestData = RequestData(url: "\(apiUrl)/sessions/\(sessionId)", method: "DELETE")
         sendRequest(requestData: requestData, onSuccess: onSuccess, onFailure: nil)
      }
   }
   
   /**
    * Send HTTP request with onFailure closure
    */
   func sendRequest(requestData: RequestData, onSuccess: @escaping ([String : Any]?) -> Void, onFailure: ((AnyObject?) -> Void)?)
   {
      guard let url = URL(string: requestData.url) else
      {
         print("Unable to create URL object")
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
      var requestData = RequestData(url: "\(apiUrl)/alarms", method: "GET")
      requestData.fields.updateValue(sessionDataMap["sessionId"] as! String, forKey: "Session-Id")
      sendRequest(requestData: requestData, onSuccess: onGetAllAlarmsSuccess)
   }
   
   func onGetAllAlarmsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let alarms = jsonData["alarms"] as? [[String: Any]]
      {
         for a in alarms
         {
            if let alarm = Alarm(json: a)
            {
               alarmCache.updateValue(alarm, forKey: alarm.id)
            }
         }
      }
   }
   
   func onReceiveNotificationSuccess(jsonData: [String : Any]?) -> Void
   {
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
      var requestData = RequestData(url: "\(apiUrl)/notifications", method: "GET")
      requestData.fields.updateValue(sessionDataMap["sessionId"] as! String, forKey: "Session-Id")
      sendRequest(requestData: requestData, onSuccess: onReceiveNotificationSuccess, onFailure: onReceiveNotificationFailure)
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
      var requestData = RequestData(url: "\(apiUrl)/objects", method: "GET")
      requestData.fields.updateValue(sessionDataMap["sessionId"] as! String, forKey: "Session-Id")
      sendRequest(requestData: requestData, onSuccess: onGetAllObjectsSuccess)
   }
   
   func onGetAllObjectsSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let objects = jsonData["objects"] as? [[String: Any]]
      {
         for o in objects
         {
            if let object = AbstractObject(json: o)
            {
               objectCache.updateValue(object, forKey: object.objectId)
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
}
