//
//  Node.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 06/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

enum NodeType: Int
{
   case UNKNOWN = 0
   case PHYSICAL = 1
   case VIRTUAL = 2
   case CONTROLLER = 3
   
   static func resolveNodeType(type: String) -> NodeType
   {
      switch (type)
      {
         case "PHYSICAL":
            return NodeType.PHYSICAL
         case "VIRTUAL":
            return NodeType.VIRTUAL
         case "CONTROLLER":
            return NodeType.CONTROLLER
         default:
            return NodeType.UNKNOWN
      }
   }
}

class Node: AbstractObject
{
   let agentVersion: String
   let bridgeBaseAddress: String
   let driverName: String
   let driverVersion: String
   let nodeType: NodeType
   var overviewDciData = [DciValue]()
   let platformName: String
   let primaryIP: String
   let primaryName: String
   let systemDescription: String
   let zoneId: Int
   
   override init(json: [String : Any])
   {
      self.agentVersion = json["agentVersion"] as? String ?? ""
      self.bridgeBaseAddress = json["bridgeBaseAddress"] as? String ?? ""
      self.driverName = json["driverName"] as? String ?? ""
      self.driverVersion = json["driverVersion"] as? String ?? ""
      self.nodeType = NodeType.resolveNodeType(type: json["nodeType"] as? String ?? "")
      self.platformName = json["platformName"] as? String ?? ""
      self.primaryIP = json["primaryIP"] as? String ?? ""
      self.primaryName = json["primaryName"] as? String ?? ""
      self.systemDescription = json["systemDescription"] as? String ?? ""
      self.zoneId = json["zoneId"] as? Int ?? -1
      
      let overviewDciData = json["overviewDciData"] as? [[String : Any]] ?? [[:]]
      for v in overviewDciData
      {
         self.overviewDciData.append(DciValue(json: v))
      }
      
      super.init(json: json)
   }
}
