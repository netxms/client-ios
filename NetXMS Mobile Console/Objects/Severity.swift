//
//  Severity.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 25/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

enum Severity: Int
{
   case NORMAL = 0
   case WARNING = 1
   case MINOR = 2
   case MAJOR = 3
   case CRITICAL = 4
   case UNKNOWN = 5
   case TERMINATE = 6
   case RESOLVE = 7
   
   static func resolveSeverity(severity: String) -> Severity
   {
      switch (severity)
      {
      case "NORMAL":
         return Severity.NORMAL
      case "WARNING":
         return Severity.WARNING
      case "MINOR":
         return Severity.MINOR
      case "MAJOR":
         return Severity.MAJOR
      case "CRITICAL":
         return Severity.CRITICAL
      case "TERMINATE":
         return Severity.TERMINATE
      case "RESOLVE":
         return Severity.RESOLVE
      default:
         return Severity.UNKNOWN
      }
   }
}
