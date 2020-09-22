//
//  iBuckSendViewControllerr.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

class iBuckSendViewControllerr: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var keyBoardVoeew: UIView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var btnContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.keyBoardVoeew.isHidden = true
        self.emailTxtField.inputAccessoryView = keyBoardVoeew
    }
    
    func setColors(){
        self.view.setColor()
        btnContinue.setiBuckViewsBackgroundColor()
        btnContinue.setiBuckButtonTextColor()
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        let vc = Utility.getiBuckSellController()
        vc.isForSend = true
        self.pushToVC(vc: vc)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyBoardVoeew.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.keyBoardVoeew.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}
