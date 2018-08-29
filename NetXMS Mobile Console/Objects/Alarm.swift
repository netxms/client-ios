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
   /**
    * Alarm states
   **/
   static private let STATE_OUTSTANDING = 0
   static private let STATE_ACKNOWLEDGED = 1
   static private let STATE_RESOLVED = 2
   static private let STATE_TERMINATED = 3
   static private let STATE_ACKNOWLEDGED_STICKY = 4
   
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
   let state: Int
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
      self.state = json["state"] as? Int ?? 0
      self.sticky = json["sticky"] as? Int ?? 0
      self.terminatedByUser = json["terminateByUser"] as? Int ?? -1
      self.timeout = json["timeout"] as? Int ?? 0
      self.timeoutEvent = json["timeoutEvent"] as? Int ?? 0
   }
}
