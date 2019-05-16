//
//  CertificateDetailsViewController.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 15/05/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit

class CertificateDetailsViewController: UIViewController {
   var subject: String!
   var pubKey: String!
   @IBOutlet weak var subjectLabel: UILabel!
   @IBOutlet weak var pubKeyLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
      subjectLabel.text = subject
      pubKeyLabel.text = pubKey
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
