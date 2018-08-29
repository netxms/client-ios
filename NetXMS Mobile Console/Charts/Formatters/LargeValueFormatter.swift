//
//  LargeValueFormatter.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 01/08/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import Charts

public class LargeValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
   
   /// Suffix to be appended after the values.
   public var suffix = ["", " k", " M", " G", " T"]
   
   /// An appendix text to be added at the end of the formatted value.
   public var appendix: String?
   
   public init(appendix: String? = nil) {
      self.appendix = appendix
   }
   
   fileprivate func format(value: Double) -> String {
      var sig = value
      var length = 0
      let maxLength = suffix.count - 1
      
      while sig >= 1000.0 && length < maxLength {
         sig /= 1000.0
         length += 1
      }
      
      var r = String(format: "%.3f", sig)
      for _ in 0..<r.count
      {
         if r.suffix(1) == "0"
         {
            r = String(r.dropLast())
         }
         else if r.suffix(1) == "."
         {
            r = String(r.dropLast())
            break
         }
      }
      r += suffix[length]
      
      if let appendix = appendix {
         r += appendix
      }
      
      return r
   }
   
   public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      return format(value: value)
   }
   
   public func stringForValue(
      _ value: Double,
      entry: ChartDataEntry,
      dataSetIndex: Int,
      viewPortHandler: ViewPortHandler?) -> String {
      return format(value: value)
   }
}
