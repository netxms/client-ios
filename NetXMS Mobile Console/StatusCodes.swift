//
//  StatusCodes.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 24/05/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import Foundation

func resolveErrorStatusCode(code: Int) -> String
{
   switch(code)
   {
   case 400:
      return "Bad Request"
   case 401:
      return "Unauthorized"
   case 402:
      return "Payment Required"
   case 403:
      return "Forbidden"
   case 404:
      return "Not Found"
   case 405:
      return "Method Not Allowed"
   case 406:
      return "Not Acceptable"
   case 407:
      return "Proxy Authentication Required"
   case 408:
      return "Request Timeout"
   case 409:
      return "Conflict"
   case 410:
      return "Gone"
   case 411:
      return "Length Required"
   case 412:
      return "Precondition Failed"
   case 413:
      return "Payload Too Large"
   case 414:
      return "URI Too Long"
   case 415:
      return "Unsupported Media Type"
   case 416:
      return "Range Not Satisfiable"
   case 417:
      return "Expectation Failed"
   case 418:
      return "Teapot"
   case 421:
      return "Misdirected Request"
   case 422:
      return "Unprocessable Entity"
   case 423:
      return "Locked"
   case 424:
      return "Failed Dependency"
   case 426:
      return "Upgrade Required"
   case 428:
      return "Precondition Required"
   case 429:
      return "Too Many Requests"
   case 431:
      return "Request Header Fields Too Large"
   case 444:
      return "No Response"
   case 451:
      return "Unavailable For Legal Reasons"
   case 495:
      return "SSL Certificate Error"
   case 496:
      return "SSL Certificate Required"
   case 497:
      return "HTTP Request Sent To HTTPS Port"
   case 499:
      return "Client Closed Request"
   case 500:
      return "Internal Server Error"
   case 501:
      return "Not Implemented"
   case 502:
      return "Bad Gateway"
   case 503:
      return "Servic eUnavailable"
   case 504:
      return "Gateway Timeout"
   case 505:
      return "HTTP Version Not Supported"
   case 506:
      return "Variant Also Negotiates"
   case 507:
      return "Insufficient Storage"
   case 508:
      return "Loop Detected"
   case 510:
      return "Not Extended"
   case 511:
      return "networkAuthenticationRequired"
   default:
      return code.description
   }
}
