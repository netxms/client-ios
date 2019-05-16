//
//  LastValuesChartController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 18/09/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import Foundation
import Charts

class LastValuesChartController: LineChartViewController
{
   @IBOutlet weak var lastValuesChart: LineChartView!
   var dciValues: [DciValue]!
   
   override func viewDidLoad()
   {
      self.lineChartView = lastValuesChart
      if dciValues.count == 1
      {
         self.title = dciValues[0].description
      }
      else
      {
         self.title = "Historical Data"
      }
      	
      var query = ""
      for dci in dciValues
      {
         query.append("\(dci.id),\(dci.nodeId),\(0),\(0),\(0),\(0);")
      }
      Connection.sharedInstance?.getHistoricalDataForMultipleObjects(query: query, onSuccess: onGetSuccess)
      
      //setChart(dataPoints: months, values: unitsSold)
      // Do any additional setup after loading the view.
      super.viewDidLoad()
   }
   
   override func onGetSuccess(jsonData: [String : Any]?)
   {
      if let jsonData = jsonData,
         let values = jsonData["values"] as? [String: Any]
      {
         var dciData = [DciData]()
         for v in values
         {
            if let v = v.value as? [String : Any]
            {
               dciData.append(DciData(json: v))
            }
         }
         
         var dataPoints = [[Double]]()
         var timeStamps = [[Double]]()
         var values = [Double]()
         var time = [Double]()
         var labels = [String]()
         for d in dciData
         {
            for v in d.values
            {
               values.append(v.value)
               time.append(Double(v.timestamp))
            }
            for dci in dciValues
            {
               if d.dciId == dci.id
               {
                  labels.append(dci.description)
               }
            }
            values.reverse()
            time.reverse()
            dataPoints.append(values)
            timeStamps.append(time)
            values.removeAll()
            time.removeAll()
         }
         
         DispatchQueue.main.async
         {
            self.setChart(dataPoints: dataPoints, values: timeStamps, labels: labels)
         }
      }
   }
   
   func setChart(dataPoints: [Double], values: [Double], label: String)
   {
      var dataEntries = [ChartDataEntry]()
      
      for i in 0..<dataPoints.count
      {
         let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
         dataEntries.append(dataEntry)
      }
      
      let chartDataSet = LineChartDataSet(entries: dataEntries, label: label)
      chartDataSet.colors = [NSUIColor.blue]
      chartDataSet.drawValuesEnabled = false
      chartDataSet.drawCirclesEnabled = false
      let chartData = LineChartData(dataSet: chartDataSet)
      lineChartView.data = chartData
   }
}
