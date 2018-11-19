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
   var parent: GraphFolder?
   var subfolders = [GraphFolder]()
   
   init(json: [String : Any])
   {
      self.name = json["name"] as? String ?? ""
      
      if let graphs = json["graphs"] as? [[String : Any]]
      {
         for g in graphs
         {
            let settings = GraphSettings(json: g)
            print(settings)
            self.graphs.append(GraphSettings(json: g))
         }
      }
      
      if let parentData = json["parent"] as? [String : Any]
      {
         self.parent = GraphFolder(json: parentData)
      }
      else
      {
         self.parent = nil
      }
      
      if let subfolders = json["subfolders"] as? [[String : Any]]
      {
         for s in subfolders
         {
            self.subfolders.append(GraphFolder(json: s))
         }
      }
   }   
}