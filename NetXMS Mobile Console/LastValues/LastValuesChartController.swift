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
   var refreshTimer: Timer!
   var timePeriod = 1
   var timeUnit = TimeUnit.TIME_UNIT_HOUR
   var from = 0
   var to = 0
   var mode = 0
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      let queryBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(queryButtonPressed))
      self.navigationItem.rightBarButtonItem = queryBarButton
      
      self.lineChartView = lastValuesChart
      if dciValues.count == 1
      {
         self.title = dciValues[0].description
      }
      else
      {
         self.title = "Historical Data"
      }
      
      self.createRefreshTimer(interval: 30)
      Connection.sharedInstance?.getHistoricalDataForMultipleObjects(query: createQuery(), onSuccess: onGetSuccess)
   }
   
   func createQuery() -> String
   {
      var query = ""
      for dci in dciValues
      {
         query.append("\(dci.id),\(dci.nodeId),\(from),\(to),\(timePeriod),\(timeUnit.rawValue);")
      }
      
      return query
   }
   
   func createRefreshTimer(interval: Double)
   {
      if refreshTimer != nil
      {
         refreshTimer.invalidate()
      }
      
      refreshTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
   }
   
   @objc func refresh()
   {
      Connection.sharedInstance?.getHistoricalDataForMultipleObjects(query: createQuery(), onSuccess: onGetSuccess)
   }
   
   func setQueryOptions(period: Int, timeUnit: TimeUnit, from: Int, to: Int)
   {
      self.timePeriod = period
      self.timeUnit = timeUnit
      self.from = from
      self.to = to
   }
   
   @objc func queryButtonPressed()
   {
      if let graphQueryVC = storyboard?.instantiateViewController(withIdentifier: "GraphQueryView") as? GraphQueryViewController
      {
         graphQueryVC.setData(view: self, refresh: Int(refreshTimer!.timeInterval), period: timePeriod, unit: timeUnit.rawValue, from: from, to: to, mode: mode)
         
         navigationController?.pushViewController(graphQueryVC, animated: true)
      }
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
         dciData = dciData.sorted(by: { (data1, data2) -> Bool in
            return data1.dciId > data2.dciId
         })
         
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
            self.lineChartView.notifyDataSetChanged()
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
   
   override func viewWillDisappear(_ animated: Bool)
   {
      super.viewWillDisappear(animated)
      
      refreshTimer.invalidate()
   }
}
