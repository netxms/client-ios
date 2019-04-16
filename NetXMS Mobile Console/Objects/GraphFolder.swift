//
//  GraphFolder.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 29/08/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

class GraphFolder
{
   var name: String
   var graphs = [GraphSettings]()
   var subfolders = [GraphFolder]()
   
   init(json: [String : Any])
   {
      self.name = json["name"] as? String ?? "[root]"
      
      if let graphs = json["graphs"] as? [String : Any]
      {
         for g in graphs.values
         {
            self.graphs.append(GraphSettings(json: g as? [String : Any] ?? [:]))
         }
      }
      
      if let subfolders = json["subfolders"] as? [String : Any]
      {
         for s in subfolders.values
         {
            self.subfolders.append(GraphFolder(json: s as? [String : Any] ?? [:]))
         }
      }
   }   
}
