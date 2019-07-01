//
//  ObjectToolsURLOutputViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 03/12/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import WebKit

class ObjectToolsURLOutputViewController: UIViewController, WKNavigationDelegate
{
   @IBOutlet var webView: WKWebView!
   var tool: ObjectTool!
   var objectId: Int!
   
   override func viewDidLoad()
    {
      super.viewDidLoad()
      
      webView.navigationDelegate = self
      
      if let url = URL(string: substituteMacros())
      {
         webView.load(URLRequest(url: url))
         webView.allowsBackForwardNavigationGestures = true
      }
    }
   
   func substituteMacros() -> String
   {
      var url = tool.data
      let object = Connection.sharedInstance?.objectCache[self.objectId] as! Node
      
      url = url.replacingOccurrences(of: "%a", with: object.primaryIP)
      url = url.replacingOccurrences(of: "%g", with: object.guid?.uuidString ?? "")
      url = url.replacingOccurrences(of: "%i", with: object.objectId.description)
      url = url.replacingOccurrences(of: "%I", with: object.objectId.description)
      url = url.replacingOccurrences(of: "%n", with: object.objectName)
      url = url.replacingOccurrences(of: "%U", with: Connection.sharedInstance?.session?.userData.name ?? "")
      url = url.replacingOccurrences(of: "%v", with: Connection.sharedInstance?.session?.serverData.version ?? "")
      url = url.replacingOccurrences(of: "%%", with: "%")
      
      return url
   }

}
