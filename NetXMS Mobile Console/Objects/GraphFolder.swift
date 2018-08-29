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
      
      if graphs = json["graphs"] as? [[String : Any]]
      {
         for g in graphs
         {
            self.graphs.append(contentsOf: GraphSettings(g))
         }
      }
      
      if parentData = json["parent"] as? [String : Any]
      {
         self.parent = GraphFolder(parentData)
      }
      else
      {
         self.parent = nil
      }
      
      if subfolders = json["subfolders"] as? [[String : Any]]
      {
         for s in subfolders
         {
            self.subfolders.append(contentsOf: GraphFolder(a))
         }
      }
   }   
}
