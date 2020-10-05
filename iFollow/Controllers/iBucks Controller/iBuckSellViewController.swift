//
//  iBuckSellViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//
import Foundation
import UIKit
import Loaf

class iBuckSellViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var valueTxtField: UITextField!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var currentBuckView: UIView!
    @IBOutlet weak var lblCurrentValue: UILabel!
    @IBOutlet weak var lblCurrentBuck: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isForSend = false
    var userId = 0
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColors()
        self.valueView.layer.cornerRadius = 15
        self.currentBuckView.layer.cornerRadius = 15
        self.keyboardView.isHidden = true
        self.valueTxtField.inputAccessoryView = keyboardView
        self.valueTxtField.text = ""
        
        valueView.isHidden = true//isForSend
        lblTopTitle.text = isForSend ? "iSend" : "iSell"
        lblHeading.text = isForSend ? "Enter iBucks you want to send" : "Enter iBucks you want to sell"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        lblCurrentValue.text = "\(Utility.getLoginUserBuck())"
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
        
        if (valueTxtField.text == ""){
            Loaf("Please enter number of iBucks", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
        }
        else{
            let bucks = Int(valueTxtField.text!)!
            if (bucks > Utility.getLoginUserBuck()){
                Loaf("Not enough iBucks", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                }
            }
            else{
                if (isForSend){
                    let vc = Utility.getiBuckPasswordController()
                    vc.isForSend = isForSend
                    vc.userId = userId
                    vc.userName = userName
                    vc.noOfBucks = bucks
                    self.pushToVC(vc: vc)
                }
                else{
                    let vc = Utility.getiBuckPayPalController()
                    vc.noOfBucks = bucks
                    self.pushToVC(vc: vc)
                }
            }
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.keyboardView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}
