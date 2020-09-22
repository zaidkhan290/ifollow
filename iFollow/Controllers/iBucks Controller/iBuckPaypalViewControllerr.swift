//
//  iBuckPaypalViewControllerr.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

class iBuckPaypalViewControllerr: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isForSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.keyboardView.isHidden = true
        self.emailTxtField.inputAccessoryView = keyboardView
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
        let vc = Utility.getiBuckPasswordController()
        vc.isForSend = isForSend
        self.pushToVC(vc: vc)
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
