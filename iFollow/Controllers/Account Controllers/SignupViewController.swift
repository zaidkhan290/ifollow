//
//  SignupViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signupText = "Already have an account? Sign In"
        let range1 = signupText.range(of: "Already have an account?")
        let range2 = signupText.range(of: "Sign In")
        
        let attributedString = NSMutableAttributedString(string: signupText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: signupText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: signupText.nsRange(from: range2!))
        btnSignIn.setAttributedTitle(attributedString, for: .normal)
        
        Utility.setTextFieldPlaceholder(textField: txtFieldEmail, placeholder: "Email", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldPassword, placeholder: "Password", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldConfirmPassword, placeholder: "Confirm Password", color: Theme.textFieldColor)
    }
    
    //MARK:- Actions
    
    @IBAction func btnStartTapped(_ sender: UIButton) {
        let vc = Utility.getSignupDetail1ViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnSignInTapped(_ sender: UIButton) {
        self.goBack()
    }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
}
