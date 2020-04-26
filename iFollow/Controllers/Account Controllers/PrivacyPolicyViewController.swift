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
        getData()
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.goBack()
    }
    
    func getData(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: isTerms ? .termsConditions : .privacyPolicy, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    self.txtView.textColor = .white
                    self.txtView.attributedText = result["message"].stringValue.htmlToAttributedString
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }

}
