//
//  SessionNotification.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 25/03/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import Foundation

enum NotificationCode: Int
{
   case UNSUPPORTED = 0
   case OBJECT_CHANGED = 4
   case OBJECT_DELETED = 99
   case ALARM_DELETED = 1003
   case NEW_ALARM = 1004
   case ALARM_CHANGED = 1005
   case ALARM_TERMINATED = 1011
   case MULTIPLE_ALARMS_TERMINATED = 1032
   case MULTIPLE_ALARMS_RESOLVED = 1033
   
   static func resolveNotificationCode(type: Int) -> NotificationCode
   {
      switch type
      {
         case 4:
            return NotificationCode.OBJECT_CHANGED
         case 99:
            return NotificationCode.OBJECT_DELETED
         case 1003:
            return NotificationCode.ALARM_DELETED
         case 1004:
            return NotificationCode.NEW_ALARM
         case 1005:
            return NotificationCode.ALARM_CHANGED
         case 1011:
            return NotificationCode.ALARM_TERMINATED
         case 1032:
            return NotificationCode.MULTIPLE_ALARMS_TERMINATED
         case 1033:
            return NotificationCode.MULTIPLE_ALARMS_RESOLVED
         default:
            return NotificationCode.UNSUPPORTED
      }
   }
}

class SessionNotification
{
   let code: NotificationCode?
   var object: AnyObject?
   let subCode: Int
   
   init(json: [String : Any])
   {
      self.object = nil
      self.code = NotificationCode.resolveNotificationCode(type: json["code"] as? Int ?? 0)
      self.subCode = json["subCode"] as? Int ?? 0
      
      switch self.code!
      {
      case NotificationCode.ALARM_CHANGED, NotificationCode.NEW_ALARM:
         self.object = Alarm(json: json["object"] as? [String : Any] ?? [:])
      case NotificationCode.MULTIPLE_ALARMS_RESOLVED, NotificationCode.MULTIPLE_ALARMS_TERMINATED:
         self.object = BulkAlarmStateChangeData(json: json["object"] as? [String : Any] ?? [:])
      case NotificationCode.OBJECT_CHANGED:
         if let objectData = json["object"] as? [String : Any]
         {
            switch ObjectClass.resolveObjectClass(objectClass: objectData["objectClass"] as? Int ?? 0)
            {
            case ObjectClass.OBJECT_NODE:
               self.object = Node(json: objectData)
            case ObjectClass.OBJECT_CLUSTER:
               self.object = Cluster(json: objectData)
            default:
               self.object = AbstractObject(json: objectData)
            }
         }
      default:
         self.object = nil
      }
   }
}

class BulkAlarmStateChangeData
{
   let alarms: [Int]?
   let userId: Int?
   let changeTime: Int?
   
   init(json: [String : Any])
   {
      self.alarms = json["alarms"] as? [Int] ?? []
      self.userId = json["userId"] as? Int ?? 0
      self.changeTime = json["changeTime"] as? Int ?? 0
   }
}
