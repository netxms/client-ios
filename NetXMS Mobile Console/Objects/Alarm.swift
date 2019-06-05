//
//  Alarm.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 22/02/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import UIKit

enum State: Int
{
   case OUTSTANDING = 0
   case ACKNOWLEDGED = 1
   case RESOLVED = 2
   case TERMINATED = 3
   case ACKNOWLEDGED_STICKY = 4
   case UNKNOWN = 5
   
   static func resolveState(state: Int) -> State
   {
      switch (state)
      {
      case 0:
         return State.OUTSTANDING
      case 1:
         return State.ACKNOWLEDGED
      case 2:
         return State.RESOLVED
      case 3:
         return State.TERMINATED
      case 4:
         return State.ACKNOWLEDGED_STICKY
      default:
         return State.UNKNOWN
      }
   }
}

class Alarm
{   
   let ackByUser: Int
   let ackTime: Int
   let commentsCount: Int
   let creationTime: Double
   let currentSeverity: Severity
   let dciId: Int
   let helpdeskReference: String
   let helpdeskState: Int
   let id: Int
   let key: String
   let lastChangeTime: Double
   let message: String
   let originalSeverity: Severity
   let repeatCount: Int
   let resolvedByUser: Int
   let sourceEventCode: Int
   let sourceEventId: Int
   let sourceObjectId: Int
   var state: State
   let sticky: Int
   let terminatedByUser: Int
   let timeout: Int
   let timeoutEvent: Int
   
   init(json: [String : Any])
   {
      self.ackByUser = json["ackByUser"] as? Int ?? -1
      self.ackTime = json["ackTime"] as? Int ?? 0
      self.commentsCount = json["commentsCount"] as? Int ?? 0
      self.creationTime = json["creationTime"] as? Double ?? 0.0
      self.currentSeverity = Severity.resolveSeverity(severity: json["currentSeverity"] as? String ?? "")
      self.dciId = json["dciId"] as? Int ?? 0
      self.helpdeskReference = json["helpdeskReference"] as? String ?? ""
      self.helpdeskState = json["helpdeskState"] as? Int ?? 0
      self.id = json["id"] as? Int ?? -1
      self.key = json["key"] as? String ?? ""
      self.lastChangeTime = json["lastChangeTime"] as? Double ?? 0.0
      self.message = json["message"] as? String ?? ""
      self.originalSeverity = Severity.resolveSeverity(severity: json["originalSeverity"] as? String ?? "")
      self.repeatCount = json["repeatCount"] as? Int ?? 0
      self.resolvedByUser = json["resolvedByUser"] as? Int ?? -1
      self.sourceEventCode = json["sourceEventCode"] as? Int ?? 0
      self.sourceEventId = json["sourceEventId"] as? Int ?? 0
      self.sourceObjectId = json["sourceObjectId"] as? Int ?? -1
      self.state = State.resolveState(state: json["state"] as? Int ?? 5)
      self.sticky = json["sticky"] as? Int ?? 0
      self.terminatedByUser = json["terminateByUser"] as? Int ?? -1
      self.timeout = json["timeout"] as? Int ?? 0
      self.timeoutEvent = json["timeoutEvent"] as? Int ?? 0
   }
}

enum AlarmAction: String
{
   case ACKNOWLEDGE = "acknowledge"
   case RESOLVE = "resolve"
   case TERMINATE = "terminate"
   case STICKY_ACKNOWLEDGE = "sticky_acknowledge"
}
