//
//  LineChartViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 31/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import Charts

class LineChartViewController: UIViewController, ChartViewDelegate {
   @IBOutlet weak var lineChartView: LineChartView!
   var dciValue: DciValue!
   var objectId: Int!
   
   override func viewDidLoad() {
        super.viewDidLoad()
      
      lineChartView.delegate = self
      
      lineChartView.dragEnabled = true
      lineChartView.setScaleEnabled(true)
      lineChartView.pinchZoomEnabled = false
      lineChartView.highlightPerDragEnabled = true
      
      lineChartView.backgroundColor = .white
      
      lineChartView.rightAxis.drawLabelsEnabled = false
      lineChartView.rightAxis.drawAxisLineEnabled = false
      
      let xAxis = lineChartView.xAxis
      xAxis.drawGridLinesEnabled = true
      xAxis.centerAxisLabelsEnabled = true
      xAxis.labelPosition = .bottom
      
      let leftAxis = lineChartView.leftAxis
      leftAxis.valueFormatter = LargeValueFormatter()
      Connection.sharedInstance?.getHistoricalData(objectId: objectId, dciId: dciValue.id, onSuccess: onGetHistoricalDataSuccess)
      //setChart(dataPoints: months, values: unitsSold)
        // Do any additional setup after loading the view.
    }

   func onGetHistoricalDataSuccess(jsonData: [String : Any]?) -> Void
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   
   @IBAction func onSliderSlide(_ sender: UISlider)
   {
      print(sender.value)
   }
   
}

public class TimestampFormatter: IndexAxisValueFormatter {
   
   init(timestamps: [Double]) {
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
