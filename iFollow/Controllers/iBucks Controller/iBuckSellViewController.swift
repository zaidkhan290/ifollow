//
//  iBuckSellViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//
import Foundation
import UIKit

class iBuckSellViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var valueTxtField: UITextField!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var currentBuckView: UIView!
    
    var isForSend = false
    
    override func viewDidLoad() {
        self.valueView.layer.cornerRadius = 15
        self.currentBuckView.layer.cornerRadius = 15
        self.keyboardView.isHidden = true
        self.valueTxtField.inputAccessoryView = keyboardView
        
        valueView.isHidden = isForSend
        lblTopTitle.text = isForSend ? "iSend" : "iSell"
        lblHeading.text = isForSend ? "Enter Bucks you want to send" : "Enter Bucks you want to sell"
    }
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton){
        if (isForSend){
            let vc = Utility.getiBuckPasswordController()
            vc.isForSend = isForSend
            self.pushToVC(vc: vc)
        }
        else{
            let vc = Utility.getiBuckPayPalController()
            self.pushToVC(vc: vc)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.keyboardView.isHidden = true
    }
}
