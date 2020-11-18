//
//  AppointmentViewController.swift
//  iFollow
//
//  Created by BSQP on 18/11/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class AppointmentViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtfieldName: UITextField!
    @IBOutlet weak var txtfieldEmail: UITextField!
    @IBOutlet weak var txtfieldContact: UITextField!
    @IBOutlet weak var txtfieldDateAndTime: UITextField!
    @IBOutlet weak var txtfieldTimezone: UITextField!
    @IBOutlet weak var txtviewDescription: UITextView!
    @IBOutlet weak var btnContinue: UIButton!
    
    var maxTxtViewHeight: CGFloat = 0.0
    var datePicker = UIDatePicker()
    var dateFormatter = DateFormatter()
    var timeZonePickerView = UIPickerView()
    
    var userEmail = ""
    var userId = 0
    var username = ""
    
    var timezones = ["AKST", "CST", "EST", "HST", "MST", "PST"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        maxTxtViewHeight = self.view.frame.height * 0.2
    }
    
    //MARK:- Methods and Actions
    
    func setData(){
        
        txtviewDescription.delegate = self
        txtfieldDateAndTime.delegate = self
        txtfieldTimezone.delegate = self
        txtviewDescription.text = "Provide some details why you want to meet..."
        txtviewDescription.textColor = Theme.captionTextViewPlaceholderColor
        
        txtfieldName.text = Utility.getLoginUserFullName()
        txtfieldEmail.text = Utility.getLoginUserEmail()
        
        dateFormatter.dateFormat = "dd MM yyyy HH:mm"
        datePicker.datePickerMode = .dateAndTime
        datePicker.timeZone = .current
        datePicker.minimumDate = Date()
        txtfieldDateAndTime.inputView = datePicker
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        timeZonePickerView.delegate = self
        txtfieldTimezone.inputView = timeZonePickerView
    }
    
    func setColors(){
        self.view.setColor()
        btnBack.setImage(UIImage(named: traitCollection.userInterfaceStyle == .dark ? "back" : "ArrowleftBlack"), for: .normal)
        btnContinue.setImage(UIImage(named: traitCollection.userInterfaceStyle == .dark ? "continue" : "continue_black"), for: .normal)
    }
    
    func scheduleAppointment(){
        
        let params = ["name": txtfieldName.text!,
                      "email": txtfieldEmail.text!,
                      "contact": txtfieldContact.text!,
                      "timezone": txtfieldTimezone.text!,
                      "date": txtfieldDateAndTime.text!,
                      "details": txtviewDescription.text!,
                      "user_email": userEmail,
                      "user_name": username,
                      "user_id": userId] as [String:Any]
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .scheduleAppointment, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.dismiss(animated: true, completion: nil)
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
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        txtfieldDateAndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton) {
        
        if (txtfieldName.text == ""){
            Loaf(kNameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (!Utility.isValid(email: txtfieldEmail.text!)){
            Loaf(kEmailError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtfieldContact.text == ""){
            Loaf(kContactError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtfieldDateAndTime.text == ""){
            Loaf(kDateTimeError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtfieldTimezone.text == ""){
            Loaf(kTimeZoneError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (txtviewDescription.text == "Provide some details why you want to meet..." || txtviewDescription.text == ""){
            Loaf(kDetailError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        scheduleAppointment()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}

extension AppointmentViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (txtviewDescription.text == "Provide some details why you want to meet..."){
            txtviewDescription.text = ""
        }
        txtviewDescription.textColor = UIColor.label
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (txtviewDescription.text == ""){
            txtviewDescription.text = "Provide some details why you want to meet..."
            txtviewDescription.textColor = Theme.captionTextViewPlaceholderColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
            let size = CGSize(width: self.view.frame.width, height: .infinity)
            let estimatedsize = textView.sizeThatFits(size)
            textView.constraints.forEach { (constraints) in
                if (estimatedsize.height < maxTxtViewHeight){
                    constraints.constant = estimatedsize.height
                }
                else{
                    constraints.constant = maxTxtViewHeight
                }
            }
    }
    
}

extension AppointmentViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == txtfieldDateAndTime && txtfieldDateAndTime.text == ""){
            txtfieldDateAndTime.text = dateFormatter.string(from: Date())
        }
        else if (textField == txtfieldTimezone && txtfieldTimezone.text == ""){
            txtfieldTimezone.text = timezones.first
        }
    }
    
}

extension AppointmentViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timezones.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timezones[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtfieldTimezone.text = timezones[row]
    }
}
