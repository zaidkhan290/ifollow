//
//  iBuckPaypalViewControllerr.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
import Loaf

class iBuckPaypalViewControllerr: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isForSend = false
    var noOfBucks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.keyboardView.isHidden = true
        self.emailTxtField.inputAccessoryView = keyboardView
        let amount = Float(noOfBucks) * 0.86
        lblBottom.text = "Note:\nYou will receive $\(String(format: "%.2f", amount)) in your paypal account"
    }
    
    func setColors(){
        self.view.setColor()
        btnContinue.setiBuckViewsBackgroundColor()
        btnContinue.setiBuckButtonTextColor()
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton){
        
        if (!Utility.isValid(email: emailTxtField.text!)){
            Loaf("Please enter your paypal email", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
        }
        else{
            let vc = Utility.getiBuckPasswordController()
            vc.isForSend = isForSend
            vc.noOfBucks = noOfBucks
            vc.paypalEmail = emailTxtField.text!
            self.pushToVC(vc: vc)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.keyboardView.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}
