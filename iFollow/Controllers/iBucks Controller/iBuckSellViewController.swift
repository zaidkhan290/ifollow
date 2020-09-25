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
    @IBOutlet weak var lblCurrentBuck: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isForSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColors()
        self.valueView.layer.cornerRadius = 15
        self.currentBuckView.layer.cornerRadius = 15
        self.keyboardView.isHidden = true
        self.valueTxtField.inputAccessoryView = keyboardView
        
        valueView.isHidden = true//isForSend
        lblTopTitle.text = isForSend ? "iSend" : "iSell"
        lblHeading.text = isForSend ? "Enter Bucks you want to send" : "Enter Bucks you want to sell"
    }
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    func setColors(){
        self.view.setColor()
        currentBuckView.setiBuckViewsBackgroundColor()
        valueView.setiBuckViewsBackgroundColor()
        lblCurrentBuck.setiBuckTextColor()
        lblValue.setiBuckTextColor()
        btnContinue.setiBuckViewsBackgroundColor()
        btnContinue.setiBuckButtonTextColor()
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}
