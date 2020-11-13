//
//  SignupViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import RealmSwift

class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var txtFieldFirstName: UITextField!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var txtFieldLastName: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var lblTermsAndConditions: UILabel!
    
//    @IBOutlet weak var iconCheck: UIImageView!
//    var isTermsAccepted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signupText = "Already have an account? Sign In"
        let range1 = signupText.range(of: "Already have an account?")
        let range2 = signupText.range(of: "Sign In")
        
        let attributedString = NSMutableAttributedString(string: signupText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: signupText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: signupText.nsRange(from: range2!))
        btnSignIn.setAttributedTitle(attributedString, for: .normal)
        
        let termsAndConditionText = "By clicking Sign up you agree to the following Terms and Conditions without reservation"
        
        let termsRange1 = termsAndConditionText.range(of: "By clicking Sign up you agree to the following ")
        let termsRange2 = termsAndConditionText.range(of: "Terms and Conditions")
        let termsRange3 = termsAndConditionText.range(of: " without reservation")
        
        let termsAttributedString = NSMutableAttributedString(string: termsAndConditionText)
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: termsAndConditionText.nsRange(from: termsRange1!))
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.termsConditionOrangeColor, range: termsAndConditionText.nsRange(from: termsRange2!))
        termsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: termsAndConditionText.nsRange(from: termsRange3!))
        
        lblTermsAndConditions.attributedText = termsAttributedString
        lblTermsAndConditions.isUserInteractionEnabled = true
        lblTermsAndConditions.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:))))
//        iconCheck.isUserInteractionEnabled = true
//        iconCheck.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconCheckTapped)))
        
        firstNameView.layer.cornerRadius = firstNameView.frame.height / 2
        lastNameView.layer.cornerRadius = lastNameView.frame.height / 2
        emailView.layer.cornerRadius = emailView.frame.height / 2
        usernameView.layer.cornerRadius = usernameView.frame.height / 2
        passwordView.layer.cornerRadius = passwordView.frame.height / 2
        
        Utility.setTextFieldPlaceholder(textField: txtFieldFirstName, placeholder: "First name", color: .white)
        Utility.setTextFieldPlaceholder(textField: txtFieldLastName, placeholder: "Last name", color: .white)
        Utility.setTextFieldPlaceholder(textField: txtFieldEmail, placeholder: "Email", color: .white)
        Utility.setTextFieldPlaceholder(textField: txtFieldUsername, placeholder: "Username", color: .white)
        Utility.setTextFieldPlaceholder(textField: txtFieldPassword, placeholder: "Password", color: .white)
        
    }
    
    //MARK:- Methods and Actions
    
    @objc func iconCheckTapped(){
//        isTermsAccepted = !isTermsAccepted
//        iconCheck.image = UIImage(named: isTermsAccepted ? "select" : "unselect")
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        let text = "By clicking Sign up you agree to the following Terms and Conditions without reservation"
        
        let termsAndConditionRange = text.range(of: " Terms and Conditions")
        
        if gesture.didTapAttributedTextInLabel(label: self.lblTermsAndConditions, inRange: text.nsRange(from: termsAndConditionRange!)) {
            let vc = Utility.getPrivacyPolicyViewController()
            vc.isTerms = true
            self.pushToVC(vc: vc)
        }
//        else if gesture.didTapAttributedTextInLabel(label: self.lblTermsAndConditions, inRange: text.nsRange(from: privacyPolicyRange!)){
//            let vc = Utility.getPrivacyPolicyViewController()
//            vc.isTerms = false
//            self.pushToVC(vc: vc)
//        }
        
    }
    
    func signupUserWithRequest(){
        
        let params = ["first_name": txtFieldFirstName.text!,
                      "last_name": txtFieldLastName.text!,
                      "date_of_birth": "",
                      "username": txtFieldUsername.text!,
                      "gender": "",
                      "short_bio": "",
                      "hobby": "",
                      "country": "",
                      "zip_code": "",
                      "email": txtFieldEmail.text!,
                      "password": txtFieldPassword.text!]
        
        let userImage = UIImage(named: "editProfilePlaceholder")
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .signup, method: .post, params: params, imageData: userImage!.jpegData(compressionQuality: 0.75)) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        realm.deleteAll()
                        let model = UserModel()
                        model.updateModelWithJSON(json: result)
                        realm.add(model)
                    }
                    let vc = Utility.getTabBarViewController()
                    self.present(vc, animated: true, completion: nil)
                }
                else{
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                
            }
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
        
        if (txtFieldFirstName.text == ""){
            Loaf(kFirstNameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtFieldLastName.text == ""){
            Loaf(kLastNameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (!Utility.isValid(email: txtFieldEmail.text!)){
            Loaf(kEmailError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtFieldUsername.text == ""){
            Loaf(kUsernameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (!Utility.isValid(password: txtFieldPassword.text!)){
            Loaf(kPasswordError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
//        else if (!isTermsAccepted){
//            Loaf(kTermsAndConditionError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(2)) { (handler) in
//
//            }
//
//        }
        signupUserWithRequest()
        
    }
    
    @IBAction func btnSignInTapped(_ sender: UIButton) {
        self.goBack()
    }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
}
