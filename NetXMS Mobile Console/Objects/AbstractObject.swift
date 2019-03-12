//
//  AbstractObject.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 16/03/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

enum ObjectClass: Int
{
   case OBJECT_GENERIC = 0
   case OBJECT_SUBNET = 1
   case OBJECT_NODE = 2
   case OBJECT_INTERFACE = 3
   case OBJECT_NETWORK = 4
   case OBJECT_CONTAINER = 5
   case OBJECT_ZONE = 6
   case OBJECT_SERVICEROOT = 7
   case OBJECT_TEMPLATE = 8
   case OBJECT_TEMPLATEGROUP = 9
   case OBJECT_TEMPLATEROOT = 10
   case OBJECT_NETWORKSERVICE = 11
   case OBJECT_VPNCONNECTOR = 12
   case OBJECT_CONDITION = 13
   case OBJECT_CLUSTER = 14
   case OBJECT_POLICYGROUP = 15
   case OBJECT_POLICYROOT = 16
   case OBJECT_AGENTPOLICY = 17
   case OBJECT_AGENTPOLICY_CONFIG = 18
   case OBJECT_NETWORKMAPROOT = 19
   case OBJECT_NETWORKMAPGROUP = 20
   case OBJECT_NETWORKMAP = 21
   case OBJECT_DASHBOARDROOT = 22
   case OBJECT_DASHBOARD = 23
   case OBJECT_BUSINESSSERVICEROOT = 27
   case OBJECT_BUSINESSSERVICE = 28
   case OBJECT_NODELINK = 29
   case OBJECT_SLMCHECK = 30
   case OBJECT_MOBILEDEVICE = 31
   case OBJECT_RACK = 32
   case OBJECT_ACCESSPOINT = 33
   case OBJECT_AGENTPOLICY_LOGPARSER = 34
   case OBJECT_CHASSIS = 35
   case OBJECT_DASHBOARDGROUP = 36
   case OBJECT_SENSOR = 37
   case OBJECT_CUSTOM = 10000
   
   static func resolveObjectClass(objectClass: Int) -> ObjectClass
   {
      switch (objectClass)
      {
      case 0:
         return ObjectClass.OBJECT_GENERIC
      case 1:
         return ObjectClass.OBJECT_SUBNET
      case 2:
         return ObjectClass.OBJECT_NODE
      case 3:
         return ObjectClass.OBJECT_INTERFACE
      case 4:
         return ObjectClass.OBJECT_NETWORK
      case 5:
         return ObjectClass.OBJECT_CONTAINER
      case 6:
         return ObjectClass.OBJECT_ZONE
      case 7:
         return ObjectClass.OBJECT_SERVICEROOT
      case 8:
         return ObjectClass.OBJECT_TEMPLATE
      case 9:
         return ObjectClass.OBJECT_TEMPLATEGROUP
      case 10:
         return ObjectClass.OBJECT_TEMPLATEROOT
      case 11:
         return ObjectClass.OBJECT_NETWORKSERVICE
      case 12:
         return ObjectClass.OBJECT_VPNCONNECTOR
      case 13:
         return ObjectClass.OBJECT_CONDITION
      case 14:
         return ObjectClass.OBJECT_CLUSTER
      case 15:
         return ObjectClass.OBJECT_POLICYGROUP
      case 16:
         return ObjectClass.OBJECT_POLICYROOT
      case 17:
         return ObjectClass.OBJECT_AGENTPOLICY
      case 18:
         return ObjectClass.OBJECT_AGENTPOLICY_CONFIG
      case 19:
         return ObjectClass.OBJECT_NETWORKMAPROOT
      case 20:
         return ObjectClass.OBJECT_NETWORKMAPGROUP
      case 21:
         return ObjectClass.OBJECT_NETWORKMAP
      case 22:
         return ObjectClass.OBJECT_DASHBOARDROOT
      case 23:
         return ObjectClass.OBJECT_DASHBOARD
      case 27:
         return ObjectClass.OBJECT_BUSINESSSERVICEROOT
      case 28:
         return ObjectClass.OBJECT_BUSINESSSERVICE
      case 29:
         return ObjectClass.OBJECT_NODELINK
      case 30:
         return ObjectClass.OBJECT_SLMCHECK
      case 31:
         return ObjectClass.OBJECT_MOBILEDEVICE
      case 32:
         return ObjectClass.OBJECT_RACK
      case 33:
         return ObjectClass.OBJECT_ACCESSPOINT
      case 34:
         return ObjectClass.OBJECT_AGENTPOLICY_LOGPARSER
      case 35:
         return ObjectClass.OBJECT_CHASSIS
      case 36:
         return ObjectClass.OBJECT_DASHBOARDGROUP
      case 37:
         return ObjectClass.OBJECT_SENSOR
      default:
         return ObjectClass.OBJECT_CUSTOM
      }
   }
}

struct Geolocation
{
   var accuracy: Int
   var latitude: Int
   var longitude: Int
   var timestamp: Int
   var type: Int
   
   init(json: [String : Any])
   {
      self.accuracy = json["accuracy"] as? Int ?? 0
      self.latitude = json["latitude"] as? Int ?? 0
      self.longitude = json["longitude"] as? Int ?? 0
      self.timestamp = json["timestamp"] as? Int ?? 0
      self.type = json["type"] as? Int ?? 0
   }
}

struct PostalAddress
{
   var city: String
   var country: String
   var postcode: String
   var streetAddress: String
   
   init(json: [String : Any])
   {
      self.city = json["city"] as? String ?? ""
      self.country = json["country"] as? String ?? ""
      self.postcode = json["postcode"] as? String ?? ""
      self.streetAddress = json["streetAddress"] as? String ?? ""
   }
}

class AbstractObject
{
   
   let geolocation: Geolocation
   let parents: [Int]
   let inMaintenanceMode: Bool
   let guid: UUID?
   let postalAddress: PostalAddress
   let objectClass: ObjectClass
   let objectId: Int
   let children: [Int]
   let dashboards: [Int]
   let objectName: String
   let status: ObjectStatus
   let statusThresholds: [Int]
   let comments: String
   let isDeleted: Bool
   
   init(json: [String : Any])
   {
      self.geolocation = Geolocation(json: json["geolocation"] as? [String : Any] ?? [:])
      self.parents = json["parents"] as? [Int] ?? []
      self.inMaintenanceMode = json["inMaintenanceMode"] as? Bool ?? false
      self.guid = UUID(uuidString: json["guid"] as? String ?? "")!
      self.postalAddress = PostalAddress(json: json["postalAddress"] as? [String : Any] ?? [:])
      self.objectClass = ObjectClass.resolveObjectClass(objectClass: (json["objectClass"] as? Int ?? 0))
      self.objectId = json["objectId"] as? Int ?? -1
      self.children = json["children"] as? [Int] ?? []
      self.dashboards = json["dashboards"] as? [Int] ?? []
      self.objectName = json["objectName"] as? String ?? "<ERROR>"
      self.status = ObjectStatus.resolveObjectStatus(status: json["status"] as? String ?? "")
      self.statusThresholds = json["statusThresholds"] as? [Int] ?? []
      self.comments = json["comments"] as? String ?? ""
      self.isDeleted = json["isDeleted"] as? Bool ?? false
   }
}

enum ObjectStatus: Int
{
   case NORMAL = 0
   case WARNING = 1
   case MINOR = 2
   case MAJOR = 3
   case CRITICAL = 4
   case UNKNOWN = 5
   
   static func resolveObjectStatus(status: String) -> ObjectStatus
   {
      switch (status)
      {
      case "NORMAL":
         return ObjectStatus.NORMAL
      case "WARNING":
         return ObjectStatus.WARNING
      case "MINOR":
         return ObjectStatus.MINOR
      case "MAJOR":
         return ObjectStatus.MAJOR
      case "CRITICAL":
         return ObjectStatus.CRITICAL
      default:
         return ObjectStatus.UNKNOWN
      }
   }
}
