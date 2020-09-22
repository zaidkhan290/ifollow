//
//  iBuckPasswordViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 21/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class iBuckPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isForSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColors()
        self.keyboardView.isHidden = true
        self.passwordTxtField.inputAccessoryView = keyboardView
        lblBottom.text = isForSend ? "Note:\nMou Navi will receive 45 Bucks in there iFollow account." : "Note:\nYou will receive $45.00 in you PayPal account."
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
