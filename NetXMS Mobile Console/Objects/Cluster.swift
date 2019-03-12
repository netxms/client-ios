//
//  Cluster.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 06/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

class Cluster: AbstractObject
{
   let zoneId: Int
   var overviewDciData = [DciValue]()
   
   override init(json: [String : Any])
   {
      self.zoneId = json["zoneId"] as? Int ?? -1
      
      let overviewDciData = json["overviewDciData"] as? [[String : Any]] ?? [[:]]
      for v in overviewDciData
      {
         self.overviewDciData.append(DciValue(json: v))
      }
      
      super.init(json: json)
   }
}
