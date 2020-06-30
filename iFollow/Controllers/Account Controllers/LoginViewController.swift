//
//  LoginViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 01/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import RealmSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
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
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //MARK:- Actions
    
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        let vc = Utility.getForgotPasswordViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnSignInTapped(_ sender: UIButton) {
        
        if (txtFieldUsername.text == ""){
            Loaf(kUsernameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (!Utility.isValid(password: txtFieldPassword.text!)){
            Loaf(kPasswordError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        loginUserWithRequest()
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        let vc = Utility.getSignupViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    //MARK:- Methods
    
    func loginUserWithRequest(){
        
        let params = ["username": txtFieldUsername.text!,
                      "password": txtFieldPassword.text!]
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .login, method: .post, params: params) { (status, result, message) in
            
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
                    UIWINDOW!.rootViewController = vc
                }
                else if (status == .blockByAdmin){
                    let alertVC = UIAlertController(title: "Activity Blocked", message: "This action was blocked by admin. Please try again later. We restrict certain content and actions to protect our community. Tell us if you think we made a mistake. Email us at support@ifollowapp.com.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                        
                    }
                    alertVC.addAction(okAction)
                    self.present(alertVC, animated: true, completion: nil)
                }
                else{
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                
            }
        }
        
    }
    
}
