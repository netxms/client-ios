//
//  ObjectToolsURLOutputViewController.swift
//  NetXMS Mobile Console
//
//  Created by Ēriks Jenkēvics on 03/12/2018.
//  Copyright © 2018 Raden Solutions. All rights reserved.
//

import UIKit
import WebKit

class ObjectToolsURLOutputViewController: UIViewController {
   @IBOutlet weak var webView: WKWebView!
   var tool: ObjectTool!
   var objectId: Int!
   
    override func viewDidLoad()
    {
      super.viewDidLoad()
      
      /*if let url = URL(string: self.url)
      {
         webView.load(URLRequest(url: url))
      }*/
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
      //url.range
      return String()
   }
   
   /*private String substituteMacros(String s, Map<String, String> inputValues)
   {

      case '{':   // object's custom attribute
      StringBuilder attr = new StringBuilder();
      for(i++; i < s.length(); i++)
      {
      if (src[i] == '}')
      break;
      attr.append(src[i]);
      }
      if ((object != null) && (attr.length() > 0))
      {
      String value = object.getCustomAttributes().get(attr.toString());
      if (value != null)
      sb.append(value);
      }
      break;
      case '(':   // input field
      StringBuilder name = new StringBuilder();
      for(i++; i < s.length(); i++)
      {
      if (src[i] == ')')
      break;
      name.append(src[i]);
      }
      if (name.length() > 0)
      {
      String value = inputValues.get(name.toString());
      if (value != null)
      sb.append(value);
      }
      break;
      default:
      break;
      }
      }
      else
      {
      sb.append(src[i]);
      }
      }
   
      return sb.toString();
   }*/
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
