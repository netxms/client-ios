//
//  TimestampFormatter.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 13/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import Charts

class TimestampFormatter: IndexAxisValueFormatter
{
   
   init(timestamps: [Double])
   {
      super.init()
      convertTimestampToDate(timestamps: timestamps)
   }
   
   private func convertTimestampToDate(timestamps: [Double])
   {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      for timestamp in timestamps
      {
         self.values.append(dateFormatter.string(from: Date(timeIntervalSince1970: timestamp)))
      }
   }
}
