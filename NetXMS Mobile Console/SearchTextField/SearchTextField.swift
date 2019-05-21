//
//  SearchTextField.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 21/05/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit

class SearchTextField: UITextField
{
   var startFilteringAfter: String?
   var minCharactersNumberToStartFiltering: Int = 0
   var forceNoFiltering: Bool = false
   var startSuggestingInmediately = false
   var comparisonOptions: NSString.CompareOptions = []
   var resultsListHeader: UIView?
   var tableXOffset: CGFloat = 0.0
   var tableYOffset: CGFloat = 0.0
   var tableCornerRadius: CGFloat = 2.0
   var tableBottomMargin: CGFloat = 10.0
   var forceRightToLeft = false
   var itemSelectionHandler: SearchTextFieldItemHandler?
   var userStoppedTypingHandler: (() -> Void)?
   var highlightAttributes: [NSAttributedString.Key: AnyObject] = [.font: UIFont.boldSystemFont(ofSize: 10)]
   var maxNumberOfResults = 0
   var maxResultsListHeight = 0
   var interactedWith = false
   var keyboardIsShowing = false
   var typingStoppedDelay = 0.8
   var startVisible = false
   var theme = SearchTextFieldTheme.lightTheme()
   {
      didSet
      {
         tableView?.reloadData()
         
         if let placeholderColor = theme.placeholderColor
         {
            if let placeholderString = placeholder
            {
               self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
            }
            
            self.placeholderLabel?.textColor = placeholderColor
         }
         
         if let hightlightedFont = self.highlightAttributes[.font] as? UIFont
         {
            self.highlightAttributes[.font] = hightlightedFont.withSize(self.theme.font.pointSize)
         }
      }
   }
   var startVisibleWithoutInteraction = false
   {
      didSet
      {
         if startVisibleWithoutInteraction
         {
            textFieldDidChange()
         }
      }
   }
   var inlineMode: Bool = false
   {
      didSet
      {
         if inlineMode == true
         {
            autocorrectionType = .no
            spellCheckingType = .no
         }
      }
   }
   
   fileprivate var currentInlineItem = ""
   fileprivate var tableView: UITableView?
   fileprivate var shadowView: UIView?
   fileprivate var direction: Direction = .down
   fileprivate var fontConversionRate: CGFloat = 0.7
   fileprivate var keyboardFrame: CGRect?
   fileprivate var timer: Timer? = nil
   fileprivate var placeholderLabel: UILabel?
   fileprivate static let cellIdentifier = "APSearchTextFieldCell"
   fileprivate let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
   fileprivate var maxTableViewSize: CGFloat = 0
   
   fileprivate var filteredResults = [SearchTextFieldItem]()
   fileprivate var filterDataSource = [SearchTextFieldItem]()
   {
      didSet
      {
         filter(forceShowAll: forceNoFiltering)
         buildSearchTableView()
         
         if startVisibleWithoutInteraction
         {
            textFieldDidChange()
         }
      }
   }
   
   deinit
   {
      NotificationCenter.default.removeObserver(self)
   }
   
   func filterItems(_ items: [SearchTextFieldItem])
   {
      filterDataSource = items
   }
   
   func filterStrings(_ strings: [String])
   {
      var items = [SearchTextFieldItem]()
      
      for value in strings
      {
         items.append(SearchTextFieldItem(title: value))
      }
      
      filterItems(items)
   }
   
   func showLoadingIndicator()
   {
      self.rightViewMode = .always
      indicator.startAnimating()
   }
   
   func stopLoadingIndicator()
   {
      self.rightViewMode = .never
      indicator.stopAnimating()
   }
   
   override func willMove(toWindow newWindow: UIWindow?)
   {
      super.willMove(toWindow: newWindow)
      tableView?.removeFromSuperview()
   }
   
   override func willMove(toSuperview newSuperview: UIView?)
   {
      super.willMove(toSuperview: newSuperview)
      
      self.addTarget(self, action: #selector(SearchTextField.textFieldDidChange), for: .editingChanged)
      self.addTarget(self, action: #selector(SearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
      self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
      self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
      
      NotificationCenter.default.addObserver(self, selector: #selector(SearchTextField.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(SearchTextField.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(SearchTextField.keyboardDidChangeFrame(_:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
   }
   
   override func layoutSubviews()
   {
      super.layoutSubviews()
      
      if inlineMode
      {
         buildPlaceholderLabel()
      } else
      {
         buildSearchTableView()
      }
      
      indicator.hidesWhenStopped = true
      self.rightView = indicator
   }
   
   override func rightViewRect(forBounds bounds: CGRect) -> CGRect
   {
      var rightFrame = super.rightViewRect(forBounds: bounds)
      rightFrame.origin.x -= 5
      return rightFrame
   }
   
   fileprivate func buildSearchTableView()
   {
      if let tableView = tableView, let shadowView = shadowView
      {
         tableView.layer.masksToBounds = true
         tableView.layer.borderWidth = theme.borderWidth > 0 ? theme.borderWidth : 0.5
         tableView.dataSource = self
         tableView.delegate = self
         tableView.separatorInset = UIEdgeInsets.zero
         tableView.tableHeaderView = resultsListHeader
         if forceRightToLeft
         {
            tableView.semanticContentAttribute = .forceRightToLeft
         }
         
         shadowView.backgroundColor = UIColor.lightText
         shadowView.layer.shadowColor = UIColor.black.cgColor
         shadowView.layer.shadowOffset = CGSize.zero
         shadowView.layer.shadowOpacity = 1
         
         self.window?.addSubview(tableView)
      } else
      {
         tableView = UITableView(frame: CGRect.zero)
         shadowView = UIView(frame: CGRect.zero)
      }
      
      redrawSearchTableView()
   }
   
   fileprivate func buildPlaceholderLabel()
   {
      var newRect = self.placeholderRect(forBounds: self.bounds)
      var caretRect = self.caretRect(for: self.beginningOfDocument)
      let textRect = self.textRect(forBounds: self.bounds)
      
      if let range = textRange(from: beginningOfDocument, to: endOfDocument)
      {
         caretRect = self.firstRect(for: range)
      }
      
      newRect.origin.x = caretRect.origin.x + caretRect.size.width + textRect.origin.x
      newRect.size.width = newRect.size.width - newRect.origin.x
      
      if let placeholderLabel = placeholderLabel
      {
         placeholderLabel.font = self.font
         placeholderLabel.frame = newRect
      } else
      {
         placeholderLabel = UILabel(frame: newRect)
         placeholderLabel?.font = self.font
         placeholderLabel?.backgroundColor = UIColor.clear
         placeholderLabel?.lineBreakMode = .byClipping
         
         if let placeholderColor = self.attributedPlaceholder?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
         {
            placeholderLabel?.textColor = placeholderColor
         } else
         {
            placeholderLabel?.textColor = UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 )
         }
         
         self.addSubview(placeholderLabel!)
      }
   }
   
   fileprivate func redrawSearchTableView()
   {
      print("redraw")
      if inlineMode
      {
         tableView?.isHidden = true
         return
      }
      
      if let tableView = tableView
      {
         guard let frame = self.superview?.convert(self.frame, to: nil) else { return }
         
         tableView.estimatedRowHeight = theme.cellHeight
         if self.direction == .down
         {
            var tableHeight: CGFloat = 0
            if keyboardIsShowing, let keyboardHeight = keyboardFrame?.size.height
            {
               tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height - keyboardHeight))
            }
            else
            {
               tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height))
            }
            
            if maxResultsListHeight > 0
            {
               tableHeight = min(tableHeight, CGFloat(maxResultsListHeight))
            }
            
            // Set a bottom margin of 10p
            if tableHeight < tableView.contentSize.height
            {
               tableHeight -= tableBottomMargin
            }
            
            var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
            tableViewFrame.origin.x += 2 + tableXOffset
            tableViewFrame.origin.y += frame.size.height + 2 + tableYOffset
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
               self?.tableView?.frame = tableViewFrame
            })
            
            var shadowFrame = CGRect(x: 0, y: 0, width: frame.size.width - 6, height: 1)
            shadowFrame.origin = self.convert(shadowFrame.origin, to: nil)
            shadowFrame.origin.x += 3
            shadowFrame.origin.y = tableView.frame.origin.y
            shadowView!.frame = shadowFrame
         }
         else
         {
            let tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - theme.cellHeight))
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
               self?.tableView?.frame = CGRect(x: frame.origin.x + 2, y: (frame.origin.y - tableHeight), width: frame.size.width - 4, height: tableHeight)
               self?.shadowView?.frame = CGRect(x: frame.origin.x + 3, y: (frame.origin.y + 3), width: frame.size.width - 6, height: 1)
            })
         }
         
         superview?.bringSubview(toFront: tableView)
         superview?.bringSubview(toFront: shadowView!)
         
         if self.isFirstResponder
         {
            superview?.bringSubview(toFront: self)
         }
         
         tableView.layer.borderColor = theme.borderColor.cgColor
         tableView.layer.cornerRadius = tableCornerRadius
         tableView.separatorColor = theme.separatorColor
         tableView.backgroundColor = theme.bgColor
         
         tableView.reloadData()
      }
   }
   
   @objc func keyboardWillShow(_ notification: Notification)
   {
      if !keyboardIsShowing && isEditing
      {
         keyboardIsShowing = true
         keyboardFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         interactedWith = true
         prepareDrawTableResult()
      }
   }
   
   @objc func keyboardWillHide(_ notification: Notification)
   {
      if keyboardIsShowing
      {
         keyboardIsShowing = false
         direction = .down
         redrawSearchTableView()
      }
   }
   
   @objc func keyboardDidChangeFrame(_ notification: Notification)
   {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
         self?.keyboardFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         self?.prepareDrawTableResult()
      }
   }
   
   @objc func typingDidStop()
   {
      self.userStoppedTypingHandler?()
   }
   
   @objc func textFieldDidChange()
   {
      if !inlineMode && tableView == nil
      {
         buildSearchTableView()
      }
      
      interactedWith = true
      
      timer?.invalidate()
      timer = Timer.scheduledTimer(timeInterval: typingStoppedDelay, target: self, selector: #selector(SearchTextField.typingDidStop), userInfo: self, repeats: false)
      
      if text!.isEmpty
      {
         clearResults()
         tableView?.reloadData()
         if startVisible || startVisibleWithoutInteraction
         {
            filter(forceShowAll: true)
         }
         self.placeholderLabel?.text = ""
      }
      else
      {
         filter(forceShowAll: forceNoFiltering)
         prepareDrawTableResult()
      }
      
      buildPlaceholderLabel()
   }
   
   @objc func textFieldDidBeginEditing()
   {
      if (startVisible || startVisibleWithoutInteraction) && text!.isEmpty
      {
         clearResults()
         filter(forceShowAll: true)
      }
      placeholderLabel?.attributedText = nil
   }
   
   @objc func textFieldDidEndEditing()
   {
      clearResults()
      tableView?.reloadData()
      placeholderLabel?.attributedText = nil
   }
   
   @objc func textFieldDidEndEditingOnExit()
   {
      if let firstElement = filteredResults.first
      {
         if let itemSelectionHandler = self.itemSelectionHandler
         {
            itemSelectionHandler(filteredResults, 0)
         }
         else
         {
            if inlineMode, let filterAfter = startFilteringAfter
            {
               let stringElements = self.text?.components(separatedBy: filterAfter)
               
               self.text = stringElements!.first! + filterAfter + firstElement.title
            } else
            {
               self.text = firstElement.title
            }
         }
      }
   }
   
   func hideResultsList()
   {
      if let tableFrame:CGRect = tableView?.frame
      {
         let newFrame = CGRect(x: tableFrame.origin.x, y: tableFrame.origin.y, width: tableFrame.size.width, height: 0.0)
         UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.tableView?.frame = newFrame
         })
         
      }
   }
   
   fileprivate func filter(forceShowAll addAll: Bool)
   {
      clearResults()
      
      if text!.count < minCharactersNumberToStartFiltering
      {
         return
      }
      
      for i in 0 ..< filterDataSource.count
      {
         let item = filterDataSource[i]
         
         if !inlineMode
         {
            let titleFilterRange = (item.title as NSString).range(of: text!, options: comparisonOptions)
            let subtitleFilterRange = item.subtitle != nil ? (item.subtitle! as NSString).range(of: text!, options: comparisonOptions) : NSMakeRange(NSNotFound, 0)
            
            if titleFilterRange.location != NSNotFound || subtitleFilterRange.location != NSNotFound || addAll
            {
               item.attributedTitle = NSMutableAttributedString(string: item.title)
               item.attributedSubtitle = NSMutableAttributedString(string: (item.subtitle != nil ? item.subtitle! : ""))
               
               item.attributedTitle!.setAttributes(highlightAttributes, range: titleFilterRange)
               
               if subtitleFilterRange.location != NSNotFound
               {
                  item.attributedSubtitle!.setAttributes(highlightAttributesForSubtitle(), range: subtitleFilterRange)
               }
               
               filteredResults.append(item)
            }
         }
         else
         {
            var textToFilter = text!.lowercased()
            
            if inlineMode, let filterAfter = startFilteringAfter
            {
               if let suffixToFilter = textToFilter.components(separatedBy: filterAfter).last, (suffixToFilter != "" || startSuggestingInmediately == true), textToFilter != suffixToFilter
               {
                  textToFilter = suffixToFilter
               }
               else
               {
                  placeholderLabel?.text = ""
                  return
               }
            }
            
            if item.title.lowercased().hasPrefix(textToFilter)
            {
               let indexFrom = textToFilter.index(textToFilter.startIndex, offsetBy: textToFilter.count)
               let itemSuffix = item.title[indexFrom...]
               
               item.attributedTitle = NSMutableAttributedString(string: String(itemSuffix))
               filteredResults.append(item)
            }
         }
      }
      
      tableView?.reloadData()
      
      if inlineMode
      {
         handleInlineFiltering()
      }
   }
   
   fileprivate func clearResults()
   {
      filteredResults.removeAll()
      tableView?.removeFromSuperview()
   }
   
   fileprivate func highlightAttributesForSubtitle() -> [NSAttributedString.Key: AnyObject]
   {
      var highlightAttributesForSubtitle = [NSAttributedString.Key: AnyObject]()
      
      for attr in highlightAttributes
      {
         if attr.0 == NSAttributedString.Key.font
         {
            let fontName = (attr.1 as! UIFont).fontName
            let pointSize = (attr.1 as! UIFont).pointSize * fontConversionRate
            highlightAttributesForSubtitle[attr.0] = UIFont(name: fontName, size: pointSize)
         }
         else
         {
            highlightAttributesForSubtitle[attr.0] = attr.1
         }
      }
      
      return highlightAttributesForSubtitle
   }
   
   func handleInlineFiltering()
   {
      if let text = self.text
      {
         if text == ""
         {
            self.placeholderLabel?.attributedText = nil
         }
         else
         {
            if let firstResult = filteredResults.first
            {
               self.placeholderLabel?.attributedText = firstResult.attributedTitle
            }
            else
            {
               self.placeholderLabel?.attributedText = nil
            }
         }
      }
   }
   
   fileprivate func prepareDrawTableResult()
   {
      guard let frame = self.superview?.convert(self.frame, to: UIApplication.shared.keyWindow) else { return }
      if let keyboardFrame = keyboardFrame
      {
         var newFrame = frame
         newFrame.size.height += theme.cellHeight
         
         if keyboardFrame.intersects(newFrame)
         {
            direction = .up
         }
         else
         {
            direction = .down
         }
         redrawSearchTableView()
      }
      else
      {
         if self.center.y + theme.cellHeight > UIApplication.shared.keyWindow!.frame.size.height
         {
            direction = .up
         }
         else
         {
            direction = .down
         }
      }
   }
}

extension SearchTextField: UITableViewDelegate, UITableViewDataSource
{
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      tableView.isHidden = !interactedWith || (filteredResults.count == 0)
      shadowView?.isHidden = !interactedWith || (filteredResults.count == 0)
      
      if maxNumberOfResults > 0
      {
         return min(filteredResults.count, maxNumberOfResults)
      }
      else
      {
         return filteredResults.count
      }
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
   {
      var cell = tableView.dequeueReusableCell(withIdentifier: SearchTextField.cellIdentifier)
      
      if cell == nil
      {
         cell = UITableViewCell(style: .subtitle, reuseIdentifier: SearchTextField.cellIdentifier)
      }
      
      cell!.backgroundColor = UIColor.clear
      cell!.layoutMargins = UIEdgeInsets.zero
      cell!.preservesSuperviewLayoutMargins = false
      cell!.textLabel?.font = theme.font
      cell!.detailTextLabel?.font = UIFont(name: theme.font.fontName, size: theme.font.pointSize * fontConversionRate)
      cell!.textLabel?.textColor = theme.fontColor
      cell!.detailTextLabel?.textColor = theme.subtitleFontColor
      
      cell!.textLabel?.text = filteredResults[(indexPath as NSIndexPath).row].title
      cell!.detailTextLabel?.text = filteredResults[(indexPath as NSIndexPath).row].subtitle
      cell!.textLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].attributedTitle
      cell!.detailTextLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].attributedSubtitle
      
      cell!.imageView?.image = filteredResults[(indexPath as NSIndexPath).row].image
      
      cell!.selectionStyle = .none
      
      return cell!
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
   {
      return theme.cellHeight
   }
   
   public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   {
      if itemSelectionHandler == nil
      {
         self.text = filteredResults[(indexPath as NSIndexPath).row].title
      }
      else
      {
         let index = indexPath.row
         itemSelectionHandler!(filteredResults, index)
      }
      clearResults()
   }
}

public struct SearchTextFieldTheme
{
   public var cellHeight: CGFloat
   public var bgColor: UIColor
   public var borderColor: UIColor
   public var borderWidth : CGFloat = 0
   public var separatorColor: UIColor
   public var font: UIFont
   public var fontColor: UIColor
   public var subtitleFontColor: UIColor
   public var placeholderColor: UIColor?
   
   init(cellHeight: CGFloat, bgColor:UIColor, borderColor: UIColor, separatorColor: UIColor, font: UIFont, fontColor: UIColor, subtitleFontColor: UIColor? = nil)
   {
      self.cellHeight = cellHeight
      self.borderColor = borderColor
      self.separatorColor = separatorColor
      self.bgColor = bgColor
      self.font = font
      self.fontColor = fontColor
      self.subtitleFontColor = subtitleFontColor ?? fontColor
   }
   
   public static func lightTheme() -> SearchTextFieldTheme
   {
      return SearchTextFieldTheme(cellHeight: 30, bgColor: UIColor (red: 1, green: 1, blue: 1, alpha: 0.6), borderColor: UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), separatorColor: UIColor.clear, font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.black)
   }
   
   public static func darkTheme() -> SearchTextFieldTheme
   {
      return SearchTextFieldTheme(cellHeight: 30, bgColor: UIColor (red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6), borderColor: UIColor (red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0), separatorColor: UIColor.clear, font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.white)
   }
}

open class SearchTextFieldItem
{
   fileprivate var attributedTitle: NSMutableAttributedString?
   fileprivate var attributedSubtitle: NSMutableAttributedString?
   public var title: String
   public var subtitle: String?
   public var image: UIImage?
   
   public init(title: String, subtitle: String?, image: UIImage?)
   {
      self.title = title
      self.subtitle = subtitle
      self.image = image
   }
   
   public init(title: String, subtitle: String?)
   {
      self.title = title
      self.subtitle = subtitle
   }
   
   public init(title: String)
   {
      self.title = title
   }
}

public typealias SearchTextFieldItemHandler = (_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void

enum Direction
{
   case down
   case up
}
