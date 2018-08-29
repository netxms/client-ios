//
//  DateValueFormatter.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 01/08/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
   private let dateFormatter = DateFormatter()
   
   override init() {
      super.init()
      dateFormatter.dateFormat = "HH:mm"
   }
   
   public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      print("Value: \(value)")
      return dateFormatter.string(from: Date(timeIntervalSince1970: value))
   }
}
