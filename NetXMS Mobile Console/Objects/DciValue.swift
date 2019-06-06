//
//  DciValue.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 11/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

enum DciDataType: Int
{
   case INT32 = 0
   case UINT32 = 1
   case INT64 = 2
   case UINT64 = 3
   case STRING = 4
   case FLOAT = 5
   case NULL = 6
   case COUNTER32 = 7
   case COUNTER64 = 8
   
   static func resolveDciDataTypeString(dataType: String) -> DciDataType
   {
      switch(dataType)
      {
      case "INT32":
         return DciDataType.INT32
      case "UINT32":
         return DciDataType.UINT32
      case "INT64":
         return DciDataType.INT64
      case "UINT64":
         return DciDataType.UINT64
      case "STRING":
         return DciDataType.STRING
      case "FLOAT":
         return DciDataType.FLOAT
      case "COUNTER32":
         return DciDataType.COUNTER32
      case "COUNTER64":
         return DciDataType.COUNTER64
      default:
         return DciDataType.NULL
      }
   }
   
   static func resolveDciDataTypeInt(dataType: Int) -> DciDataType
   {
      switch(dataType)
      {
      case 0:
         return DciDataType.INT32
      case 1:
         return DciDataType.UINT32
      case 2:
         return DciDataType.INT64
      case 3:
         return DciDataType.UINT64
      case 4:
         return DciDataType.STRING
      case 5:
         return DciDataType.FLOAT
      case 7:
         return DciDataType.COUNTER32
      case 8:
         return DciDataType.COUNTER64
      default:
         return DciDataType.NULL
      }
   }
}

class Threshold
{
   let id: Int
   let fireEvent: Int
   let rearmEvent: Int
   let sampleCount: Int
   let function: Int
   let operation: Int
   let script: String
   let repeatInterval: Int
   let value: String
   let active: Bool
   let currentSeverity: Severity
   let lastEventTimestamp: Double
   
   init?(json: [String : Any])
   {
      guard let id = json["id"] as? Int,
         let fireEvent = json["fireEvent"] as? Int,
         let rearmEvent = json["rearmEvent"] as? Int,
         let sampleCount = json["sampleCount"] as? Int,
         let function = json["function"] as? Int,
         let operation = json["operation"] as? Int,
         let script = json["script"] as? String,
         let repeatInterval = json["repeatInterval"] as? Int,
         let value = json["value"] as? String,
         let active = json["active"] as? Bool,
         let currentSeverity = json["currentSeverity"] as? String,
         let lastEventTimestamp = json["lastEventTimestamp"] as? Double
         else
      {
         return nil
      }
      
      self.id = id
      self.fireEvent = fireEvent
      self.rearmEvent = rearmEvent
      self.sampleCount = sampleCount
      self.function = function
      self.operation = operation
      self.script = script
      self.repeatInterval = repeatInterval
      self.value = value
      self.active = active
      self.currentSeverity = Severity.resolveSeverity(severity: currentSeverity)
      self.lastEventTimestamp = lastEventTimestamp
   }
}

class DciValue
{
   let dcObjectType: Int
   let name: String
   let value: Double
   let source: Int
   let id: Int
   let errorCount: Int
   let templateDciId: Int
   let status: Int
   let description: String
   let nodeId: Int
   let timestamp: Double
   let dataType: DciDataType
   let activeThreshold: Threshold?
   
   init(json: [String : Any])
   {
      self.dcObjectType = json["dcObjectType"] as? Int ?? -1
      self.name = json["name"] as? String ?? ""
      self.value = Double(json["value"] as? String ?? "") ?? -1
      self.source = json["source"] as? Int ?? -1
      self.id = json["id"] as? Int ?? 0
      self.errorCount = json["errorCount"] as? Int ?? 0
      self.templateDciId = json["templateDciId"] as? Int ?? 0
      self.status = json["status"] as? Int ?? 0
      self.description = json["description"] as? String ?? ""
      self.nodeId = json["nodeId"] as? Int ?? -1
      self.timestamp = json["timestamp"] as? Double ?? 0.0
      self.activeThreshold = Threshold(json: json["activeThreshold"] as? [String : Any] ?? [:])
      
      if let dataType = json["dataType"] as? String
      {
         self.dataType = DciDataType.resolveDciDataTypeString(dataType: dataType)
      }
      else if let dataType = json["dataType"] as? Int
      {
         self.dataType = DciDataType.resolveDciDataTypeInt(dataType: dataType)
      }
      else
      {
         self.dataType = DciDataType.NULL
      }
   }
}
