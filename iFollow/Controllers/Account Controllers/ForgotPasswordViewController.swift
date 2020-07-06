//
//  ForgotPasswordViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Toast_Swift
import Loaf

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var lblResetPassword: UILabel!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblResetPassword.setShadow(color: UIColor.white)
        Utility.setTextFieldPlaceholder(textField: txtFieldEmail, placeholder: "Username or Email Address", color: Theme.textFieldColor)
        
        let signupText = "Still haven't an Account? Sign Up"
        let range1 = signupText.range(of: "Still haven't an Account?")
        let range2 = signupText.range(of: "Sign Up")
        
        let attributedString = NSMutableAttributedString(string: signupText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: signupText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: signupText.nsRange(from: range2!))
        btnSignup.setAttributedTitle(attributedString, for: .normal)
    }
    
    //MARK:- Actions
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        
        if (!Utility.isValid(email: txtFieldEmail.text!)){
            Loaf(kEmailError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        forgotPasswordWithRequest()
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        let vc = Utility.getSignupViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    //MARK:- Methods
    
    func forgotPasswordWithRequest(){
        
        let params = ["email": txtFieldEmail.text!]
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .forgotPassword, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.goBack()
                    }
                }
                else{
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                
            }
        }
    }
}
