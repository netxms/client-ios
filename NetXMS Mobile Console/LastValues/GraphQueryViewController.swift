//
//  GraphQueryViewController.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 10/06/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit

extension CALayer {
   
   func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
      
      let border = CALayer()
      
      switch edge {
      case .top:
         border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
      case .bottom:
         border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
      case .left:
         border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
      case .right:
         border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
      default:
         break
      }
      
      border.backgroundColor = color.cgColor;
      
      addSublayer(border)
   }
}

class GraphQueryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
   @IBOutlet var periodPickerStack: UIStackView!
   @IBOutlet var periodStackHeight: NSLayoutConstraint!
   @IBOutlet var periodView: UIView!
   @IBOutlet var periodCancel: UIButton!
   @IBOutlet var periodConfirm: UIButton!
   @IBOutlet var periodPicker: UIPickerView!
   @IBOutlet var unitLabel: UILabel!
   @IBOutlet var periodLabel: UILabel!
   @IBOutlet var toCancel: UIButton!
   @IBOutlet var toConfirm: UIButton!
   @IBOutlet var fromCancel: UIButton!
   @IBOutlet var fromConfirm: UIButton!
   @IBOutlet var toDatePicker: UIDatePicker!
   @IBOutlet var fromDatePicker: UIDatePicker!
   @IBOutlet var toStackHeight: NSLayoutConstraint!
   @IBOutlet var fromStackHeight: NSLayoutConstraint!
   @IBOutlet var toPickerStack: UIStackView!
   @IBOutlet var fromPickerStack: UIStackView!
   @IBOutlet var toLabel: UILabel!
   @IBOutlet var fromLabel: UILabel!
   @IBOutlet var toView: UIView!
   @IBOutlet var fromView: UIView!
   @IBOutlet var refreshView: UIView!
   @IBOutlet var refreshCounter: UILabel!
   @IBOutlet var refreshSlider: UISlider!
   @IBOutlet var selector: UISegmentedControl!
   var lastValuesChartVC: LastValuesChartController!
   var refresh: Int!
   var period: Int!
   var unit: Int!
   var from: Int!
   var to: Int!
   var mode: Int!
   var cancelPressed = false
   let dateFormatter = DateFormatter()
   
   let timeUnits = ["Minutes", "Hours", "Days"]
   let numbers: [Int] = Array(0...60)
   
   func roundCorners(views: [UIView])
   {
      for view in views
      {
         view.layer.cornerRadius = 4
         view.layer.shadowColor = UIColor(red:0.03, green:0.08, blue:0.15, alpha:0.3).cgColor
         view.layer.shadowOpacity = 1
         view.layer.shadowOffset = CGSize(width: 0, height: 4)
         view.layer.shadowRadius = 4
      }
   }
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
      cancelButton.tintColor = .red
      self.navigationItem.rightBarButtonItem = cancelButton
      
      periodPicker.delegate = self
      periodPicker.dataSource = self
      
      fromView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFromTap)))
      toView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onToTap)))
      periodView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPeriodTap)))
      
      periodConfirm.addTarget(self, action: #selector(onPeriodTap), for: .touchUpInside)
      toConfirm.addTarget(self, action: #selector(onToTap), for: .touchUpInside)
      fromConfirm.addTarget(self, action: #selector(onFromTap), for: .touchUpInside)
      
      periodCancel.addTarget(self, action: #selector(onPeriodCancel), for: .touchUpInside)
      toCancel.addTarget(self, action: #selector(onToCancel), for: .touchUpInside)
      fromCancel.addTarget(self, action: #selector(onFromCancel), for: .touchUpInside)
   }
   
   @objc func onPeriodCancel()
   {
      closePeriod()
      periodPicker.selectRow(self.unit, inComponent: 1, animated: false)
      periodPicker.selectRow(self.period, inComponent: 0, animated: false)
   }
   
   @objc func onToCancel()
   {
      closeTo()
      //toDatePicker.setDate(Date(timeIntervalSince1970: TimeInterval(to)), animated: true)
   }
   
   @objc func onFromCancel()
   {
      closeFrom()
      //fromDatePicker.setDate(Date(timeIntervalSince1970: TimeInterval(from)), animated: true)
   }
   
   override func viewDidLayoutSubviews()
   {
      fromView.layer.addBorder(edge: .top, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      fromView.layer.addBorder(edge: .bottom, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      toView.layer.addBorder(edge: .top, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      toView.layer.addBorder(edge: .bottom, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      refreshView.layer.addBorder(edge: .top, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      refreshView.layer.addBorder(edge: .bottom, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      fromCancel.layer.borderWidth = 1
      fromCancel.layer.borderColor = #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1)
      fromCancel.layer.cornerRadius = 4
      fromConfirm.layer.borderWidth = 1
      fromConfirm.layer.borderColor = #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1)
      fromConfirm.layer.cornerRadius = 4
      toCancel.layer.borderWidth = 1
      toCancel.layer.borderColor = #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1)
      toCancel.layer.cornerRadius = 4
      toConfirm.layer.borderWidth = 1
      toConfirm.layer.borderColor = #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1)
      toConfirm.layer.cornerRadius = 4
      periodView.layer.addBorder(edge: .top, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      periodView.layer.addBorder(edge: .bottom, color: #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1), thickness: 1)
      periodCancel.layer.borderWidth = 1
      periodCancel.layer.borderColor = #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1)
      periodCancel.layer.cornerRadius = 4
      periodConfirm.layer.borderWidth = 1
      periodConfirm.layer.borderColor = #colorLiteral(red: 0.8966716528, green: 0.8966716528, blue: 0.8966716528, alpha: 1)
      periodConfirm.layer.cornerRadius = 4
   }
   
   @objc func onPeriodTap()
   {
      if periodStackHeight.constant == 0
      {
         openPeriod()
      }
      else
      {
         periodLabel.text = numbers[periodPicker.selectedRow(inComponent: 0)].description
         unitLabel.text = timeUnits[periodPicker.selectedRow(inComponent: 1)]
         closePeriod()
      }
   }
   
   @objc func onFromTap()
   {
      if fromStackHeight.constant == 0
      {
         openFrom()
         closeTo()
      }
      else
      {
         fromLabel.text = dateFormatter.string(from: fromDatePicker.date)
         closeFrom()
      }
   }
   
   @objc func onToTap()
   {
      if toStackHeight.constant == 0
      {
         openTo()
         closeFrom()
      }
      else
      {
         toLabel.text = dateFormatter.string(from: toDatePicker.date)
         closeTo()
      }
   }
   
   @objc func cancel()
   {
      cancelPressed = true
      self.navigationController?.popViewController(animated: true)
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      super.viewWillDisappear(animated)
      
      if cancelPressed
      {
         return
      }
      
      if selector.selectedSegmentIndex == 0
      {
         lastValuesChartVC.setQueryOptions(period: periodPicker.selectedRow(inComponent: 0), timeUnit: TimeUnit.resolveTimeUnit(unit: periodPicker.selectedRow(inComponent: 1)), from: 0, to: 0)
      }
      else if selector.selectedSegmentIndex == 1
      {
         lastValuesChartVC.setQueryOptions(period: 0, timeUnit: TimeUnit.resolveTimeUnit(unit: periodPicker.selectedRow(inComponent: 0)), from: Int(fromDatePicker.date.timeIntervalSince1970), to: Int(toDatePicker.date.timeIntervalSince1970))
      }
      lastValuesChartVC.mode = selector.selectedSegmentIndex
      
      Connection.sharedInstance?.getHistoricalDataForMultipleObjects(query: lastValuesChartVC.createQuery(), onSuccess: lastValuesChartVC.onGetSuccess)
      let refresh = refreshSlider.value == 0 ? 30 : Int(refreshSlider.value)
      lastValuesChartVC.createRefreshTimer(interval: Double(refresh))
   }
   
   override func viewWillAppear(_ animated: Bool)
   {
      refreshSlider.value = Float(refresh)
      selector.selectedSegmentIndex = mode
      onSelectorValueChange(UISegmentedControl())
      onIntervalSliderValueChange(AnyClass.self)
      
      if from != 0 && to != 0
      {
         fromDatePicker.setDate(Date(timeIntervalSince1970: TimeInterval(from)), animated: true)
         toDatePicker.setDate(Date(timeIntervalSince1970: TimeInterval(to)), animated: true)
      }
      
      dateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
      
      fromLabel.text = dateFormatter.string(from: fromDatePicker.date)
      toLabel.text = dateFormatter.string(from: toDatePicker.date)
      
      periodPicker.selectRow(self.unit, inComponent: 1, animated: false)
      periodPicker.selectRow(self.period, inComponent: 0, animated: false)
      
      periodLabel.text = numbers[periodPicker.selectedRow(inComponent: 0)].description
      unitLabel.text = timeUnits[periodPicker.selectedRow(inComponent: 1)]
   }
   
   func setData(view: LastValuesChartController, refresh: Int, period: Int, unit: Int, from: Int, to: Int, mode: Int)
   {
      lastValuesChartVC = view
      self.refresh = refresh
      self.period = period
      self.unit = unit
      self.from = from
      self.to = to
      self.mode = mode
   }
   
   @objc func closePeriod()
   {
      periodPicker.isHidden = true
      UIView.animate(withDuration: 0.3, animations:
      {
         self.periodPickerStack.alpha = 0
         self.periodStackHeight.constant = 0
         self.view.layoutIfNeeded()
      })
   }
   
   func openPeriod()
   {
      periodPicker.isHidden = false
      UIView.animate(withDuration: 0.3, animations:
      {
         self.periodPickerStack.alpha = 1
         self.periodStackHeight.constant = 245
         self.view.layoutIfNeeded()
      })
   }
   
   func hidePeriod()
   {
      closePeriod()
      periodView.isHidden = true
   }
   
   func showPeriod()
   {
      periodView.isHidden = false
      closePeriod()
   }
   
   @objc func closeFrom()
   {
      fromDatePicker.isHidden = true
      UIView.animate(withDuration: 0.3)
      {
         self.fromPickerStack.alpha = 0
         self.fromStackHeight.constant = 0
         self.view.layoutIfNeeded()
      }
   }
   
   func openFrom()
   {
      fromDatePicker.isHidden = false
      UIView.animate(withDuration: 0.3)
      {
         self.fromPickerStack.alpha = 1
         self.fromStackHeight.constant = 245
         self.view.layoutIfNeeded()
      }
   }
   
   @objc func closeTo()
   {
      toDatePicker.isHidden = true
      UIView.animate(withDuration: 0.3)
      {
         self.toPickerStack.alpha = 0
         self.toStackHeight.constant = 0
         self.view.layoutIfNeeded()
      }
   }
   
   func openTo()
   {
      toDatePicker.isHidden = false
      UIView.animate(withDuration: 0.3)
      {
         self.toPickerStack.alpha = 1
         self.toStackHeight.constant = 245
         self.view.layoutIfNeeded()
      }
   }
   
   func hideFrom()
   {
      closeFrom()
      fromView.isHidden = true
   }
   
   func showTo()
   {
      closeTo()
      toView.isHidden = false
   }
   
   func hideTo()
   {
      closeTo()
      toView.isHidden = true
   }
   
   func showFrom()
   {
      closeFrom()
      fromView.isHidden = false
   }
   
   func showFixedTime()
   {
      showTo()
      showFrom()
   }
   
   func hideFixedTime()
   {
      hideFrom()
      hideTo()
   }
   
   @IBAction func onSelectorValueChange(_ sender: UISegmentedControl)
   {
      if selector.selectedSegmentIndex == 0
      {
         showPeriod()
         hideFixedTime()
      }
      else if selector.selectedSegmentIndex == 1
      {
         hidePeriod()
         showFixedTime()
      }
   }
   
   @IBAction func onIntervalSliderValueChange(_ sender: Any)
   {
      refreshCounter.text = Int(refreshSlider.value).description
   }
   
   func numberOfComponents(in pickerView: UIPickerView) -> Int
   {
      return 2
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
   {
      if component == 0
      {
         return numbers.count
      }
      else
      {
         return timeUnits.count
      }
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
   {
      if component == 0
      {
         return numbers[row].description
      }
      else
      {
         return timeUnits[row]
      }
   }
}
