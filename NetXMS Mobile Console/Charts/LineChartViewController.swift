//
//  LineChartViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 31/07/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import Charts
    
class LineChartViewController: UIViewController, ChartViewDelegate
{
   @IBOutlet weak var lineChartView: LineChartView!
   private static var colors = [#colorLiteral(red: 0.9374830127, green: 0.7647051215, blue: 0.2834933698, alpha: 1), #colorLiteral(red: 0.493791759, green: 0.8472803831, blue: 0.9028527141, alpha: 1), #colorLiteral(red: 0.9172777534, green: 0.3934337199, blue: 0.3254517317, alpha: 1), #colorLiteral(red: 0.7853129506, green: 0.3688077331, blue: 0.7202036381, alpha: 1), #colorLiteral(red: 0.5162566304, green: 0.4526287913, blue: 0.6893087029, alpha: 1), #colorLiteral(red: 0.6138263941, green: 0.1128861979, blue: 0, alpha: 1), #colorLiteral(red: 0.9657973647, green: 0.6442337632, blue: 0.6350688934, alpha: 1), #colorLiteral(red: 0.5081598163, green: 0.1944012642, blue: 0.4601449966, alpha: 1)]
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      lineChartView.delegate = self
      
      lineChartView.dragEnabled = true
      lineChartView.setScaleEnabled(true)
      lineChartView.pinchZoomEnabled = true
      lineChartView.highlightPerDragEnabled = true
      
      lineChartView.backgroundColor = .darkGray
      
      lineChartView.rightAxis.drawLabelsEnabled = false
      lineChartView.rightAxis.drawAxisLineEnabled = false
      lineChartView.rightAxis.axisLineColor = UIColor.lightGray
      lineChartView.rightAxis.labelTextColor = .lightGray
      
      let xAxis = lineChartView.xAxis
      xAxis.drawGridLinesEnabled = true
      xAxis.centerAxisLabelsEnabled = true
      xAxis.labelPosition = .bottom
      xAxis.labelTextColor = .lightGray
      
      let leftAxis = lineChartView.leftAxis
      leftAxis.axisLineColor = UIColor.lightGray
      leftAxis.labelTextColor = .lightGray
      leftAxis.valueFormatter = LargeValueFormatter()
      
      lineChartView.legend.textColor = .lightGray
   }
   
   func getColor(index: Int) -> UIColor
   {
      if index < LineChartViewController.colors.count
      {
         return LineChartViewController.colors[index]
      }
      else
      {
         let randomColor = UIColor(red: CGFloat(arc4random_uniform(256))/255, green: CGFloat(arc4random_uniform(256))/255, blue: CGFloat(arc4random_uniform(256))/255, alpha: 1)
         LineChartViewController.colors.append(randomColor)
         return randomColor
      }
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
         let chartDataSet = LineChartDataSet(entries: dataEntries, label: labels[i])
         chartDataSet.colors = [getColor(index: i)]
         chartDataSet.drawValuesEnabled = false
         chartDataSet.drawCirclesEnabled = false
         chartDataSet.drawFilledEnabled = true
         chartDataSet.fillColor = getColor(index: i)
         dataSets.append(chartDataSet)
         dataEntries.removeAll()
      }
      
      let chartData = LineChartData(dataSets: dataSets)
      lineChartView.data = chartData
   }
}
