//
//  ObjectTool.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 19/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

enum ObjectToolType: Int
{
   case TYPE_INTERNAL = 0
   case TYPE_ACTION = 1
   case TYPE_TABLE_SNMP = 2
   case TYPE_TABLE_AGENT = 3
   case TYPE_URL = 4
   case TYPE_LOCAL_COMMAND = 5
   case TYPE_SERVER_COMMAND = 6
   case TYPE_FILE_DOWNLOAD = 7
   case TYPE_SERVER_SCRIPT = 8
   
   static func resolveObjectToolType(type: Int) -> ObjectToolType
   {
      switch type {
      case 0:
         return ObjectToolType.TYPE_INTERNAL
      case 1:
         return ObjectToolType.TYPE_ACTION
      case 2:
         return ObjectToolType.TYPE_TABLE_SNMP
      case 3:
         return ObjectToolType.TYPE_TABLE_AGENT
      case 4:
         return ObjectToolType.TYPE_URL
      case 5:
         return ObjectToolType.TYPE_LOCAL_COMMAND
      case 6:
         return ObjectToolType.TYPE_SERVER_COMMAND
      case 7:
         return ObjectToolType.TYPE_FILE_DOWNLOAD
      default:
         return ObjectToolType.TYPE_SERVER_SCRIPT
      }
   }
}

class ObjectTool
{
   let id: Int
   let name: String
   let displayName: String
   let type: ObjectToolType
   let description: String
   let commandName: String
   let commandShortName: String
   var inputFields: [String : InputField]
   
   init(json: [String : Any])
   {
      self.id = json["id"] as? Int ?? 0
      self.name = json["name"] as? String ?? ""
      self.displayName = json["displayName"] as? String ?? ""
      self.type = ObjectToolType.resolveObjectToolType(type: json["type"] as? Int ?? 0)
      self.description = json["description"] as? String ?? ""
      self.commandName = json["commandName"] as? String ""
      self.commandShortName = json["commandShortName"] as? String ""
      //self.inputFields
   }
}

class InputField
{
   
}
