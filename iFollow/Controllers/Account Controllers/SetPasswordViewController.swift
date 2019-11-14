//
//  SetPasswordViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class SetPasswordViewController: UIViewController {
    
    @IBOutlet weak var lblNewPassword: UILabel!
    @IBOutlet weak var txtFieldOldPassword: UITextField!
    @IBOutlet weak var txtFieldNewPassword: UITextField!
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        self.lblNewPassword.setShadow(color: UIColor.white)
        Utility.setTextFieldPlaceholder(textField: txtFieldOldPassword, placeholder: "Old Password", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldNewPassword, placeholder: "New Password", color: Theme.textFieldColor)
        Utility.setTextFieldPlaceholder(textField: txtFieldConfirmPassword, placeholder: "Confirm Password", color: Theme.textFieldColor)
        
        let signupText = "Still haven't an Account? Sign Up"
        let range1 = signupText.range(of: "Still haven't an Account?")
        let range2 = signupText.range(of: "Sign Up")
        
        let attributedString = NSMutableAttributedString(string: signupText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: signupText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: signupText.nsRange(from: range2!))
        btnSignUp.setAttributedTitle(attributedString, for: .normal)
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnResetTapped(_ sender: UIButton) {
        self.view.makeToast("Password change successfully")
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        let vc = Utility.getSignupViewController()
        self.pushToVC(vc: vc)
    }
    
    
}
