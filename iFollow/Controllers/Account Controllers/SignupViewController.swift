//
//  SignupViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class SignupViewController: UIViewController {
    
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var lblTermsAndConditions: UILabel!
    @IBOutlet weak var iconCheck: UIImageView!
    var isTermsAccepted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signupText = "Already have an account? Sign In"
        let range1 = signupText.range(of: "Already have an account?")
        let range2 = signupText.range(of: "Sign In")
        
        let attributedString = NSMutableAttributedString(string: signupText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: signupText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: signupText.nsRange(from: range2!))
        btnSignIn.setAttributedTitle(attributedString, for: .normal)
        
        let termsAndConditionText = "Yes, I understand and agree to the Terms & Conditions and Privacy Policy"
        
        let termsRange1 = termsAndConditionText.range(of: "Yes, I understand and agree to the ")
        let termsRange2 = termsAndConditionText.range(of: "Terms & Conditions")
        let termsRange3 = termsAndConditionText.range(of: " and ")
        let termsRange4 = termsAndConditionText.range(of: "Privacy Policy")
        
        let termsAttributedString = NSMutableAttributedString(string: termsAndConditionText)
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: termsAndConditionText.nsRange(from: termsRange1!))
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: termsAndConditionText.nsRange(from: termsRange2!))
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: termsAndConditionText.nsRange(from: termsRange3!))
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: termsAndConditionText.nsRange(from: termsRange4!))
        
        lblTermsAndConditions.attributedText = termsAttributedString
        lblTermsAndConditions.isUserInteractionEnabled = true
        lblTermsAndConditions.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:))))
        iconCheck.isUserInteractionEnabled = true
        iconCheck.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconCheckTapped)))
        
        Utility.setTextFieldPlaceholder(textField: txtFieldEmail, placeholder: "Email", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldPassword, placeholder: "Password", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldConfirmPassword, placeholder: "Confirm Password", color: Theme.textFieldColor)
    }
    
    //MARK:- Methods and Actions
    
    @objc func iconCheckTapped(){
        isTermsAccepted = !isTermsAccepted
        iconCheck.image = UIImage(named: isTermsAccepted ? "select" : "unselect")
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        let text = "Yes, I understand and agree to the Terms & Conditions and Privacy Policy"
        
        let termsAndConditionRange = text.range(of: " Terms & Conditions")
        let privacyPolicyRange = text.range(of: "Privacy Policy")
        
        if gesture.didTapAttributedTextInLabel(label: self.lblTermsAndConditions, inRange: text.nsRange(from: termsAndConditionRange!)) {
            let vc = Utility.getPrivacyPolicyViewController()
            vc.isTerms = true
            self.pushToVC(vc: vc)
        }
        else if gesture.didTapAttributedTextInLabel(label: self.lblTermsAndConditions, inRange: text.nsRange(from: privacyPolicyRange!)){
            let vc = Utility.getPrivacyPolicyViewController()
            vc.isTerms = false
            self.pushToVC(vc: vc)
        }
        
    }
    
    func checkIfEmailIsAvailable(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["email": txtFieldEmail.text!]
        
        API.sharedInstance.executeAPI(type: .checkEmail, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    let vc = Utility.getSignupDetail1ViewController()
                    let userModel = UserModel()
                    userModel.userEmail = self.txtFieldEmail.text!
                    userModel.userPassword = self.txtFieldPassword.text!
                    vc.userModel = userModel
                    self.pushToVC(vc: vc)
                }
                else{
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func btnStartTapped(_ sender: UIButton) {
        
        if (!Utility.isValid(email: txtFieldEmail.text!)){
            Loaf(kEmailError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (!Utility.isValid(password: txtFieldPassword.text!)){
            Loaf(kPasswordError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtFieldConfirmPassword.text! != txtFieldPassword.text!){
            Loaf(kPasswordNotMatchError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (!isTermsAccepted){
            Loaf(kTermsAndConditionError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(2)) { (handler) in
                
            }
            
        }
        checkIfEmailIsAvailable()
        
    }
    
    @IBAction func btnSignInTapped(_ sender: UIButton) {
        self.goBack()
    }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
}
