//
//  iBuckPasswordViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 21/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import RealmSwift

class iBuckPasswordViewController: UIViewController {

    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isForSend = false
    var userId = 0
    var userName = ""
    var noOfBucks = 0
    var paypalEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColors()
        passwordTxtField.isSecureTextEntry = true
        self.keyboardView.isHidden = true
        self.passwordTxtField.inputAccessoryView = keyboardView
        let amount = Float(noOfBucks) * 0.86
        lblBottom.text = isForSend ? "Note:\n\(userName) will receive \(noOfBucks) Bucks in their iFollow account." : "Note:\nYou will receive $\(amount) in your paypal account"
    }
    
    //MARK:- Methods and Actions
    
    func setColors(){
        self.view.setColor()
        btnContinue.setiBuckViewsBackgroundColor()
        btnContinue.setiBuckButtonTextColor()
    }
    
    func validatePassword(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["password": passwordTxtField.text!]
        
        API.sharedInstance.executeAPI(type: .validatePassword, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    if (self.isForSend){
                        self.sendiBuckToUser()
                    }
                    else{
                        self.selliBucks()
                    }
                    
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

                    }
                   
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
    func sendiBuckToUser(){
        
        let params = ["ibucks": noOfBucks,
                      "user_id": userId]
        
        API.sharedInstance.executeAPI(type: .sendBuck, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

                    }
                    
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        if let model = UserModel.getCurrentUser(){
                            model.userBuck = result["ibucks"].intValue
                        }
                    }
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
    
    func selliBucks(){
        let params = ["ibucks": noOfBucks,
                      "paypal_email": paypalEmail] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .sellBuck, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        if let model = UserModel.getCurrentUser(){
                            model.userBuck = result["ibucks"].intValue
                        }
                    }
                    
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton){
        if (passwordTxtField.text == ""){
            Loaf("Please enter your iFollow password", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

            }
            return
        }
        validatePassword()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}

extension iBuckPasswordViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = true
    }
}
