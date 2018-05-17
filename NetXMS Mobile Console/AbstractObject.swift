//
//  AbstractObject.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 16/03/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

struct Geolocation
{
   var accuracy: Int
   var latitude: Int
   var longitude: Int
   var timestamp: Int
   var type: Int
   
   init?(json: [String : Any])
   {
      if let accuracy = json["accuracy"] as? Int,
         let latitude = json["latitude"] as? Int,
         let longitude = json["longitude"] as? Int,
         let timestamp = json["timestamp"] as? Int,
         let type = json["type"] as? Int
      {
         self.accuracy = accuracy
         self.latitude = latitude
         self.longitude = longitude
         self.timestamp = timestamp
         self.type = type
      }
      else
      {
         self.accuracy = 0
         self.latitude = 0
         self.longitude = 0
         self.timestamp = 0
         self.type = 0
      }
      
      
   }
}

struct PostalAddress
{
   var city: String
   var country: String
   var postcode: String
   var streetAddress: String
   
   init?(json: [String : Any])
   {
      if let city = json["city"] as? String,
         let country = json["country"] as? String,
         let postcode = json["postcode"] as? String,
         let streetAddress = json["streetAddress"] as? String
      {
         self.city = city
         self.country = country
         self.postcode = postcode
         self.streetAddress = streetAddress
      }
      else
      {
         self.city = ""
         self.country = ""
         self.postcode = ""
         self.streetAddress = ""
      }
   }
}

struct AccessListElement
{
   let accessRights: Int
   let userId: Int
   
   init?(json: [String : Any])
   {
      guard let accessRights = json["accessRights"] as? Int,
         let userId = json["userId"] as? Int
      else
      {
         return nil
      }
      
      self.accessRights = accessRights
      self.userId = userId
   }
}

class AbstractObject
{
   let geolocation: Geolocation
   let parents: [Int]
   let trustedNodes: [Int]
   let inheritAccessRights: Bool
   let inMaintenanceMode: Bool
   let statusPropagationMethod: Int
   let statusSingleThreshold: Int
   let statusShift: Int
   var accessList = [AccessListElement]()
   let guid: UUID
   let statusCalculationMethod: Int
   let customAttributes: [String : String]
   let postalAddress: PostalAddress
   let image: UUID
   let fixedPropagatedStatus: String
   let urls: [String]
   let statusTransformation: [String]
   let objectClass: Int
   let objectId: Int
   let children: [Int]
   let dashboards: [Int]
   let objectName: String
   let drillDownObjectId: Int
   let status: String
   let responsibleUsers: [Int]
   let isDeleted: Bool
   let statusThresholds: [Int]
   let comments: String
   
   init?(json: [String : Any])
   {
      guard let geolocation = json["geolocation"] as? [String : Any],
         let parents = json["parents"] as? [Int],
         let trustedNodes = json["trustedNodes"] as? [Int],
         let inheritAccessRights = json["inheritAccessRights"] as? Bool,
         let inMaintenanceMode = json["inMaintenanceMode"] as? Bool,
         let statusPropagationMethod = json["statusPropagationMethod"] as? Int,
         let statusSingleThreshold = json["statusSingleThreshold"] as? Int,
         let statusShift = json["statusShift"] as? Int,
         let accessList = json["accessList"] as? [[String : Any]],
         let guid = json["guid"] as? String,
         let statusCalculationMethod = json["statusCalculationMethod"] as? Int,
         let customAttributes = json["customAttributes"] as? [String : String],
         let postalAddress = json["postalAddress"] as? [String : Any],
         let image = json["image"] as? String,
         let fixedPropagatedStatus = json["fixedPropagatedStatus"] as? String,
         let objectClass = json["objectClass"] as? Int,
         let objectId = json["objectId"] as? Int,
         let children = json["children"] as? [Int],
         let dashboards = json["dashboards"] as? [Int],
         let objectName = json["objectName"] as? String,
         let drillDownObjectId = json["drillDownObjectId"] as? Int,
         let status = json["status"] as? String,
         let responsibleUsers = json["responsibleUsers"] as? [Int],
         let isDeleted = json["isDeleted"] as? Bool,
         let statusThresholds = json["statusThresholds"] as? [Int],
         let comments = json["comments"] as? String
      else
      {
         return nil
      }
      
      self.geolocation = Geolocation(json: geolocation)!
      self.parents = [Int](parents)
      self.trustedNodes = [Int](trustedNodes)
      self.inheritAccessRights = inheritAccessRights
      self.inMaintenanceMode = inMaintenanceMode
      self.statusPropagationMethod = statusPropagationMethod
      self.statusSingleThreshold = statusSingleThreshold
      self.statusShift = statusShift
      for e in accessList
      {
         if let element = AccessListElement(json: e)
         {
            self.accessList.append(element)
         }
      }
      self.guid = UUID(uuidString: guid)!
      self.statusCalculationMethod = statusCalculationMethod
      self.customAttributes = customAttributes
      self.postalAddress = PostalAddress(json: postalAddress)!
      self.image = UUID(uuidString: image)!
      self.fixedPropagatedStatus = fixedPropagatedStatus
      if let urls = json["urls"] as? [String]
      {
         self.urls = [String](urls)
      }
      else
      {
         self.urls = [String]()
      }
      if let statusTransformation = json["statusTransformation"] as? [String]
      {
         self.statusTransformation = [String](statusTransformation)
      }
      else
      {
         self.statusTransformation = [String]()
      }
      self.objectClass = objectClass
      self.objectId = objectId
      self.children = children
      self.dashboards = dashboards
      self.objectName = objectName
      self.drillDownObjectId = drillDownObjectId
      self.status = status
      self.responsibleUsers = responsibleUsers
      self.isDeleted = isDeleted
      self.statusThresholds = statusThresholds
      self.comments = comments
   }
   
}
