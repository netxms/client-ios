//
//  CertificateDetailsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 15/05/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit
import Foundation

class CertificateDetailsViewController: UIViewController {
   var subject: String!
   var pubKey: String!
   var completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)!
   var trust: SecTrust!
   var certData: Data!
   @IBOutlet weak var subjectLabel: UILabel!
   @IBOutlet weak var pubKeyLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
      subjectLabel.text = subject
      pubKeyLabel.text = pubKey
    }
    
   @IBAction func cancelPressed(_ sender: Any)
   {
      completionHandler(.cancelAuthenticationChallenge, nil)
      self.dismiss(animated: true, completion: nil)
   }
   
   @IBAction func acceptPRessed(_ sender: Any)
   {
      try? AppDelegate.keychain.set(certData, key: Connection.sharedInstance!.apiUrl)
      completionHandler(.useCredential, URLCredential(trust: trust))
      self.dismiss(animated: true, completion: nil)
   }
}
