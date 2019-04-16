//
//  DciData.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 10/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

class DciData
{
   var nodeId: Int
   var dciId: Int
   var dataType: DataType
   var values = [DciDataRow]()
   
   init(json: [String : Any])
   {
      self.nodeId = json["nodeId"] as? Int ?? 0
      self.dciId = json["dciId"] as? Int ?? 0
      self.dataType = DataType.resolveDataType(type: json["dataType"] as? String ?? "")
      
      let values = json["values"] as? [[String : Any]] ?? [[:]]
      for v in values
      {
         self.values.append(DciDataRow(json: v))
      }
   }
}

enum DataType: Int
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
   
   static func resolveDataType(type: String) -> DataType
   {
      switch type
      {
         case "INT32":
            return DataType.INT32
         case "UINT32":
            return DataType.UINT32
         case "INT64":
            return DataType.INT64
         case "UINT64":
            return DataType.UINT64
         case "STRING":
            return DataType.STRING
         case "FLOAT":
            return DataType.FLOAT
         case "COUNTER32":
            return DataType.COUNTER32
         case "COUNTER64":
            return DataType.COUNTER64
         default:
            return DataType.NULL
      }
   }
}

class DciDataRow
{
   var timestamp: Int
   var value: Double
   var rawValue: Double
   
   init(json: [String : Any])
   {
      self.timestamp = json["timestamp"] as? Int ?? 0
      self.value = json["value"] as? Double ?? 0
      self.rawValue = json["rawValue"] as? Double ?? 0
   }
}
