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
   static let colors = [NSUIColor.blue, NSUIColor.brown, NSUIColor.green, NSUIColor.red, NSUIColor.yellow, NSUIColor.orange, NSUIColor.cyan, NSUIColor.black]
   
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
      // Do any additional setup after loading the view.
   }
   
   func onGetSuccess(jsonData: [String : Any]?) -> Void
   {
      return
   }
   
   func setChart(dataPoints: [[Double]], values: [[Double]], labels: [String])
   {
      self.lineChartView.xAxis.valueFormatter = TimestampFormatter(timestamps: values[0])
      var dataSets = [LineChartDataSet]()
      
      for i in 0..<dataPoints.count
      {
         var dataEntries = [ChartDataEntry]()
         for n in 0..<dataPoints[i].count
         {
            let dataEntry = ChartDataEntry(x: Double(n), y: dataPoints[i][n])
            dataEntries.append(dataEntry)
         }
         let chartDataSet = LineChartDataSet(values: dataEntries, label: labels[i])
         chartDataSet.colors = [LineChartViewController.colors[i]]
         chartDataSet.drawValuesEnabled = false
         chartDataSet.drawCirclesEnabled = false
         dataSets.append(chartDataSet)
         dataEntries.removeAll()
      }
      
      let chartData = LineChartData(dataSets: dataSets)
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
