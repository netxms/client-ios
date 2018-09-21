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
   var dciValue: DciValue!
   var objectId: Int!
   
   override func viewDidLoad() {
      self.lineChartView = lastValuesChart
      super.viewDidLoad()
      
      
      
      Connection.sharedInstance?.getHistoricalData(objectId: objectId, dciId: dciValue.id, onSuccess: onGetSuccess)
      //setChart(dataPoints: months, values: unitsSold)
      // Do any additional setup after loading the view.
   }
   
   override func onGetSuccess(jsonData: [String : Any]?) -> Void
   {
      if let jsonData = jsonData,
         let data = jsonData["values"] as? [String : Any],
         let values = data["values"] as? [[String : Any]]
      {
         var timestamps = [Double]()
         var data = [Double]()
         
         for value in values
         {
            timestamps.append((value["timestamp"] as! Double))
            data.append((value["value"] as! Double))
         }
         timestamps.reverse()
         data.reverse()
         self.lineChartView.xAxis.valueFormatter = TimestampFormatter(timestamps: timestamps)
         DispatchQueue.main.async
            {
               self.setChart(dataPoints: timestamps, values: data, label: self.dciValue.description)
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
      
      let chartDataSet = LineChartDataSet(values: dataEntries, label: label)
      chartDataSet.colors = [NSUIColor.blue]
      chartDataSet.drawValuesEnabled = false
      chartDataSet.drawCirclesEnabled = false
      let chartData = LineChartData(dataSet: chartDataSet)
      lineChartView.data = chartData
   }
}
