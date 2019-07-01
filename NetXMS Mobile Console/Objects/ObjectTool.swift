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

enum InputFieldType: Int
{
   case TEXT = 0
   case PASSWORD = 1
   case NUMBER = 2
   
   static func resolveInputFieldType(type: String) -> InputFieldType
   {
      switch type {
      case "TEXT":
         return InputFieldType.TEXT
      case "PASSWORD":
         return InputFieldType.PASSWORD
      default:
         return InputFieldType.NUMBER
         
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
   var inputFields = [String : InputField]()
   let data: String
   
   init(json: [String : Any])
   {
      self.id = json["id"] as? Int ?? 0
      self.name = json["name"] as? String ?? ""
      self.displayName = json["displayName"] as? String ?? ""
      self.type = ObjectToolType.resolveObjectToolType(type: json["type"] as? Int ?? 0)
      self.description = json["description"] as? String ?? ""
      self.commandName = json["commandName"] as? String ?? ""
      self.commandShortName = json["commandShortName"] as? String ?? ""
      self.data = json["data"] as? String ?? ""
      
      if let fields = json["inputFields"] as? [String : [String : Any]]
      {
         for f in fields
         {
            let field = InputField(json: f.value)
            self.inputFields.updateValue(field, forKey: field.name)
         }
      }
   }
}

class ObjectToolFolder
{
   let name: String
   let displayName: String
   var subfolders = [ObjectToolFolder]()
   var tools = [ObjectTool]()
   
   init(json: [String : Any])
   {
      self.name = json["name"] as? String ?? ""
      self.displayName = json["displayName"] as? String ?? ""
      
      if let tools = json["tools"] as? [String : [String : Any]]
      {
         for t in tools.values
         {
            let type = ObjectToolType.resolveObjectToolType(type: t["type"] as? Int ?? 0)
            if type == .TYPE_ACTION || type == .TYPE_SERVER_COMMAND || type == .TYPE_URL
            {
               self.tools.append(ObjectTool(json: t))
            }
         }
      }
      
      if let subfolders = json["subfolders"] as? [String : [String : Any]]
      {
         for s in subfolders.values
         {
            self.subfolders.append(ObjectToolFolder(json: s))
         }
      }
   }
   
   func isEmpty() -> Bool
   {
      var result = tools.isEmpty
      for folder in subfolders
      {
         result = folder.isEmpty()
      }
      
      return result
   }
}

class InputField
{
   var name: String
   var type: InputFieldType
   var displayName: String
   var sequence: Int
   var options: InputFieldOptions
   
   init(json: [String : Any])
   {
      self.name = json["name"] as? String ?? ""
      self.type = InputFieldType.resolveInputFieldType(type: json["type"] as? String ?? "")
      self.displayName = json["displayName"] as? String ?? ""
      self.sequence = json["sequence"] as? Int ?? 0
      self.options = InputFieldOptions(json: json["options"] as? [String : Any] ?? [:])
   }
}

class InputFieldOptions
{
   var validatePassword: Bool
   
   init(json: [String : Any])
   {
      self.validatePassword = json["validatePassword"] as? Bool ?? false
   }
}

