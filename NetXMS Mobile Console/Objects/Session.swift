//
//  Session.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 30/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

class ServerData
{
   let address: String
   let serverName: String
   let color: String
   let id: Int
   let timeZone: String
   let version: String
   
   init?(json: [String : Any])
   {
      guard let address = json["address"] as? String,
         let serverName = json["serverName"] as? String,
         let color = json["color"] as? String,
         let id = json["id"] as? Int,
         let timeZone = json["timeZone"] as? String,
         let version = json["version"] as? String
         else
      {
         return nil
      }
      
      self.serverName = serverName
      self.address = address
      self.color = color
      self.id = id
      self.timeZone = timeZone
      self.version = version
   }
}

class UserData
{
   let globalAccessRights: Int
   let id: Int
   let name: String
   
   init?(json: [String : Any])
   {
      guard let globalAccessRights = json["globalAccessRights"] as? Int,
         let id = json["id"] as? Int,
         let name = json["name"] as? String
         else
      {
         return nil
      }
      
      self.globalAccessRights = globalAccessRights
      self.id = id
      self.name = name
   }
}

class Session
{
   let encrypted: Bool
   let objectsSynchronized: Bool
   let passwordExpired: Bool
   let serverData: ServerData
   let userData: UserData
   let zoningEnabled: Bool
   let handle: UUID
   
   init?(json: [String : Any])
   {
      if let sessionData = json["session"] as? [String : Any]
      {
         guard let encrypted = sessionData["encrypted"] as? Bool,
            let objectsSynchronized = sessionData["objectsSynchronized"] as? Bool,
            let passwordExpired = sessionData["passwordExpired"] as? Bool,
            let serverData = sessionData["server"] as? [String : Any],
            let userData = sessionData["user"] as? [String : Any],
            let zoningEnabled = sessionData["zoningEnabled"] as? Bool,
            let handle = json["sessionHandle"] as? String
            else
         {
            return nil
         }
         
         self.encrypted = encrypted
         self.objectsSynchronized = objectsSynchronized
         self.passwordExpired = passwordExpired
         self.serverData = ServerData(json: serverData)!
         self.userData = UserData(json: userData)!
         self.zoningEnabled = zoningEnabled
         self.handle = UUID.init(uuidString: handle)!
      }
      else
      {
         return nil
      }
   }
}
