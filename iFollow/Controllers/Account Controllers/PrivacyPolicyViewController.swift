//
//  PrivacyPolicyViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 30/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var txtView: UITextView!
    var isTerms = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeading.text = isTerms ? "Terms and Conditions" : "Privacy Policy"
        txtView.text = isTerms ? "This is dummy terms and conditions text. This is dummy terms and conditions text. This is dummy terms and conditions text. This is dummy terms and conditions text. \n\nThis is dummy terms and conditions text. This is dummy terms and conditions text. This is dummy terms and conditions text. This is dummy terms and conditions text." : "This is dummy privacy policy text. This is dummy privacy policy text. This is dummy privacy policy text. This is dummy privacy policy text. \n\nThis is dummy privacy policy text. This is dummy privacy policy text. This is dummy privacy policy text. This is dummy privacy policy text."
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.goBack()
    }

}
