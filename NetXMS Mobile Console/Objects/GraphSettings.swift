//
//  GraphSettings.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 29/08/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation

enum TimeUnit: Int
{
   case TIME_UNIT_MINUTE = 0
   case TIME_UNIT_HOUR = 1
   case TIME_UNIT_DAY = 2
   
   static func resolveTimeUnit(unit: Int) -> TimeUnit
   {
      switch unit {
      case 1:
         return TimeUnit.TIME_UNIT_HOUR
      case 2:
         return TimeUnit.TIME_UNIT_DAY
      default:
         return TimeUnit.TIME_UNIT_MINUTE
      }
   }
}

enum TimeFrameType: Int
{
   case TIME_FRAME_FIXED = 0
   case TIME_FRAME_BACK_FROM_NOW = 1
   case TIME_FRAME_CURRENT = 2
   
   static func resolveTimeFrameType(type: Int) -> TimeFrameType
   {
      switch type {
      case 1:
         return TimeFrameType.TIME_FRAME_BACK_FROM_NOW
      case 2:
         return TimeFrameType.TIME_FRAME_CURRENT
      default:
         return TimeFrameType.TIME_FRAME_FIXED
      }
   }
}

class GraphSettings: ChartConfig
{
   var id: Int
   var name: String
   var shortName: String
   var dciList = [ChartDciConfig]()
   
   override init(json: [String : Any])
   {
      self.id = json["id"] as? Int ?? 0
      self.name = json["name"] as? String ?? ""
      self.shortName = json["shortName"] as? String ?? ""
      
      let overviewDciData = json["dciList"] as? [[String : Any]] ?? [[:]]
      for d in overviewDciData
      {
         self.dciList.append(ChartDciConfig(json: d))
      }
      
      super.init(json: json)
   }
}

class ChartConfig
{
   var title: String
   //var legendPosition: LegendPosition
   var showLegend: Bool
   var extendedLegend: Bool
   var showTitle: Bool
   var showGrid: Bool
   var showHostNames: Bool
   var autoRefresh: Bool
   var logScale: Bool
   var stacked: Bool
   var translucent: Bool
   var area: Bool
   var lineWidth: Int
   var autoScale: Bool
   var minYScaleValue: Int
   var maxYScaleValue: Int
   var refreshRate: Int
   var timeUnits: TimeUnit
   var timeFrameType: TimeFrameType
   var timeRange: Int
   var timeFrom: Int
   var timeTo: Int
   var modifyYBase: Bool
   var useMultipliers: Bool
   
   init(json: [String : Any])
   {
      self.title = json["title"] as? String ?? ""
      //self.legendPosition: LegendPosition
      self.showLegend = json["showLegend"] as? Bool ?? true
      self.extendedLegend = json["extendedLegend"] as? Bool ?? true
      self.showTitle = json["showTitle"] as? Bool ?? false
      self.showGrid = json["showGrid"] as? Bool ?? true
      self.showHostNames = json["showHostNames"] as? Bool ?? false
      self.autoRefresh = json["autoRefresh"] as? Bool ?? true
      self.logScale = json["logScale"] as? Bool ?? false
      self.stacked =  json["stacked"] as? Bool ?? false
      self.translucent = json["translucent"] as? Bool ?? true
      self.area = json["area"] as? Bool ?? false
      self.lineWidth = json["lineWidth"] as? Int ?? 2
      self.autoScale = json["autoScale"] as? Bool ?? true
      self.minYScaleValue = json["minYScaleValue"] as? Int ?? 0
      self.maxYScaleValue = json["maxYScaleValue"] as? Int ?? 100
      self.refreshRate = json["refreshRate"] as? Int ?? 30
      self.timeUnits = TimeUnit.resolveTimeUnit(unit: json["timeUnits"] as? Int ?? 0)
      self.timeFrameType = TimeFrameType.resolveTimeFrameType(type: json["timeFrameType"] as? Int ?? 0)
      self.timeRange = json["timeRange"] as? Int ?? 1
      self.timeFrom = json["timeFrom"] as? Int ?? 0
      self.timeTo = json["timeTo"] as? Int ?? 0
      self.modifyYBase =  json["modifyYBase"] as? Bool ?? false
      self.useMultipliers = json["useMultipliers"] as? Bool ?? true
   }
}

class ChartDciConfig
{
   var nodeId: Int
   var dciId: Int
   var dciName: String
   var dciDescription: String
   var type: Int
   var color: String
   var name: String
   var lineWidth: Int
   var displayType: Int
   var area: Bool
   var showThresholds: Bool
   var invertValues: Bool
   var multiMatch: Bool
   var instance: String
   var column: String
   var displayFormat: String
   
   init(json: [String : Any])
   {
      self.nodeId = json["nodeId"] as? Int ?? 0
      self.dciId = json["dciId"] as? Int ?? 0
      self.dciName = json["dciName"] as? String ?? ""
      self.dciDescription = json["dciDescription"] as? String ?? ""
      self.type = json["type"] as? Int ?? 0
      self.color = json["color"] as? String ?? ""
      self.name = json["name"] as? String ?? ""
      self.lineWidth = json["lineWidth"] as? Int ?? 0
      self.displayType = json["displayType"] as? Int ?? 0
      self.area = json["area"] as? Bool ?? false
      self.showThresholds = json["showThresholds"] as? Bool ?? false
      self.invertValues = json["invertValues"] as? Bool ?? false
      self.multiMatch = json[""] as? Bool ?? false
      self.instance = json["Instance"] as? String ?? ""
      self.column = json["column"] as? String ?? ""
      self.displayFormat = json["displayFormat"] as? String ?? ""
   }
}
