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
   /*
    * Object clases
    */
   static public let OBJECT_GENERIC = 0;
   static public let OBJECT_SUBNET = 1;
   static public let OBJECT_NODE = 2;
   static public let OBJECT_INTERFACE = 3;
   static public let OBJECT_NETWORK = 4;
   static public let OBJECT_CONTAINER = 5;
   static public let OBJECT_ZONE = 6;
   static public let OBJECT_SERVICEROOT = 7;
   static public let OBJECT_TEMPLATE = 8;
   static public let OBJECT_TEMPLATEGROUP = 9;
   static public let OBJECT_TEMPLATEROOT = 10;
   static public let OBJECT_NETWORKSERVICE = 11;
   static public let OBJECT_VPNCONNECTOR = 12;
   static public let OBJECT_CONDITION = 13;
   static public let OBJECT_CLUSTER = 14;
   static public let OBJECT_POLICYGROUP = 15;
   static public let OBJECT_POLICYROOT = 16;
   static public let OBJECT_AGENTPOLICY = 17;
   static public let OBJECT_AGENTPOLICY_CONFIG = 18;
   static public let OBJECT_NETWORKMAPROOT = 19;
   static public let OBJECT_NETWORKMAPGROUP = 20;
   static public let OBJECT_NETWORKMAP = 21;
   static public let OBJECT_DASHBOARDROOT = 22;
   static public let OBJECT_DASHBOARD = 23;
   static public let OBJECT_BUSINESSSERVICEROOT = 27;
   static public let OBJECT_BUSINESSSERVICE = 28;
   static public let OBJECT_NODELINK = 29;
   static public let OBJECT_SLMCHECK = 30;
   static public let OBJECT_MOBILEDEVICE = 31;
   static public let OBJECT_RACK = 32;
   static public let OBJECT_ACCESSPOINT = 33;
   static public let OBJECT_AGENTPOLICY_LOGPARSER = 34;
   static public let OBJECT_CHASSIS = 35;
   static public let OBJECT_DASHBOARDGROUP = 36;
   static public let OBJECT_SENSOR = 37;
   static public let OBJECT_CUSTOM = 10000;
   
   let geolocation: Geolocation
   let parents: [Int]
   let inMaintenanceMode: Bool
   let guid: UUID?
   let postalAddress: PostalAddress
   let objectClass: Int
   let objectId: Int
   let children: [Int]
   let dashboards: [Int]
   let objectName: String
   let status: ObjectStatus
   //let responsibleUsers: [Int]
   let statusThresholds: [Int]
   let comments: String
   
   init(json: [String : Any])
   {
      self.geolocation = Geolocation(json: json["geolocation"] as? [String : Any] ?? [:])
      self.parents = json["parents"] as? [Int] ?? []
      self.inMaintenanceMode = json["inMaintenanceMode"] as? Bool ?? false
      self.guid = UUID(uuidString: json["guid"] as? String ?? "")!
      self.postalAddress = PostalAddress(json: json["postalAddress"] as? [String : Any] ?? [:])
      self.objectClass = json["objectClass"] as? Int ?? 0
      self.objectId = json["objectId"] as? Int ?? -1
      self.children = json["children"] as? [Int] ?? []
      self.dashboards = json["dashboards"] as? [Int] ?? []
      self.objectName = json["objectName"] as? String ?? "<ERROR>"
      self.status = AbstractObject.resolveObjectStatus(status: json["status"] as? String ?? "")
      //let responsibleUsers = json["responsibleUsers"] as? [Int]
      self.statusThresholds = json["statusThresholds"] as? [Int] ?? []
      self.comments = json["comments"] as? String ?? ""
   }
   
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

enum ObjectStatus: Int
{
   case NORMAL = 0
   case WARNING = 1
   case MINOR = 2
   case MAJOR = 3
   case CRITICAL = 4
   case UNKNOWN = 5
}
