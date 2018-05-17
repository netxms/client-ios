//
//  Alarm.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 22/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit

class Alarm
{
   static private let STATE_OUTSTANDING = 0
   static private let STATE_ACKNOWLEDGED = 1
   static private let STATE_RESOLVED = 2
   static private let STATE_TERMINATED = 3
   static private let STATE_ACKNOWLEDGED_STICKY = 4
   
   let ackByUser: Int
   let ackTime: Int
   let commentsCount: Int
   let creationTime: Double
   let currentSeverity: String
   let dciId: Int
   let helpdeskReference: String
   let helpdeskState: Int
   let id: Int
   let key: String
   let lastChangeTime: Double
   let message: String
   let originalSeverity: String
   let repeatCount: Int
   let resolvedByUser: Int
   let sourceEventCode: Int
   let sourceEventId: Int
   let sourceObjectId: Int
   let state: Int
   let sticky: Int
   let terminatedByUser: Int
   let timeout: Int
   let timeoutEvent: Int
   
   init?(json: [String : Any])
   {
      guard let ackByUser = json["ackByUser"] as? Int,
         let ackTime = json["ackTime"] as? Int,
         let commentsCount = json["commentsCount"] as? Int,
         let creationTime = json["creationTime"] as? Double,
         let currentSeverity = json["currentSeverity"] as? String,
         let dciId = json["dciId"] as? Int,
         let helpdeskReference = json["helpdeskReference"] as? String,
         let helpdeskState = json["helpdeskState"] as? Int,
         let id = json["id"] as? Int,
         let key = json["key"] as? String,
         let lastChangeTime = json["lastChangeTime"] as? Double,
         let message = json["message"] as? String,
         let originalSeverity = json["originalSeverity"] as? String,
         let repeatCount = json["repeatCount"] as? Int,
         let resolvedByUser = json["resolvedByUser"] as? Int,
         let sourceEventCode = json["sourceEventCode"] as? Int,
         let sourceEventId = json["sourceEventId"] as? Int,
         let sourceObjectId = json["sourceObjectId"] as? Int,
         let state = json["state"] as? Int,
         let sticky = json["sticky"] as? Int,
         let terminatedByUser = json["terminateByUser"] as? Int,
         let timeout = json["timeout"] as? Int,
         let timeoutEvent = json["timeoutEvent"] as? Int
      else
      {
         return nil
      }
      
      self.ackByUser = ackByUser
      self.ackTime = ackTime
      self.commentsCount = commentsCount
      self.creationTime = creationTime
      self.currentSeverity = currentSeverity
      self.dciId = dciId
      self.helpdeskReference = helpdeskReference
      self.helpdeskState = helpdeskState
      self.id = id
      self.key = key
      self.lastChangeTime = lastChangeTime
      self.message = message
      self.originalSeverity = originalSeverity
      self.repeatCount = repeatCount
      self.resolvedByUser = resolvedByUser
      self.sourceEventCode = sourceEventCode
      self.sourceEventId = sourceEventId
      self.sourceObjectId = sourceObjectId
      self.state = state
      self.sticky = sticky
      self.terminatedByUser = terminatedByUser
      self.timeout = timeout
      self.timeoutEvent = timeoutEvent
   }
   
   func getAlarmStateIcon() -> UIImage
   {
      switch(self.state)
      {
      case Alarm.STATE_OUTSTANDING:
         return UIImage(named: "outstanding")!
      case Alarm.STATE_ACKNOWLEDGED:
         return UIImage(named: "acknowledged")!
      case Alarm.STATE_RESOLVED:
         return UIImage(named: "resolved")!
      case Alarm.STATE_TERMINATED:
         return UIImage(named: "terminated")!
      default:
         return UIImage(named: "acknowledged_sticky")!
      }
   }
}
