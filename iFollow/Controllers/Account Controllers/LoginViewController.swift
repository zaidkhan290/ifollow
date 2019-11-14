//
//  LoginViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 01/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    var isForForgotPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let signupText = "Don't have an Account? Sign Up"
        let range1 = signupText.range(of: "Don't have an Account?")
        let range2 = signupText.range(of: "Sign Up")
        
        let attributedString = NSMutableAttributedString(string: signupText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: signupText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: signupText.nsRange(from: range2!))
        btnSignup.setAttributedTitle(attributedString, for: .normal)
        
        Utility.setTextFieldPlaceholder(textField: txtFieldUsername, placeholder: "Username", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldPassword, placeholder: "Password", color: Theme.textFieldColor)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(isForForgotPassword){
            self.view.makeToast("Code sent to your email")
        }
    }
    
    //MARK:- Actions
    
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        isForForgotPassword = true
        let vc = Utility.getForgotPasswordViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnSignInTapped(_ sender: UIButton) {
        isForForgotPassword = false
        let vc = Utility.getTabBarViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        isForForgotPassword = false
        let vc = Utility.getSignupViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        isForForgotPassword = false
        self.goBack()
    }
    
}
