//
//  SignupDetail2ViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import RealmSwift
import SKCountryPicker

class SignupDetail2ViewController: UIViewController {

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTableView: UITableView!
    
    var textFieldPlaceholders = [String]()
    var textFieldImages = [String]()
    
    var userModel = UserModel()
    var userImage = UIImage()
    var shortBio = ""
    var hobby = ""
    var userCountry = ""
    var zipCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailView.roundTopCorners(radius: 30)
        
        let imageCellNib = UINib(nibName: "EditProfileImageTableViewCell", bundle: nil)
        let txtFieldCellNib = UINib(nibName: "EditProfileTextFieldsTableViewCell", bundle: nil)
        let doneButtonCellNib = UINib(nibName: "EditProfileSaveButtonTableViewCell", bundle: nil)
        
        detailTableView.register(imageCellNib, forCellReuseIdentifier: "EditProfileImageTableViewCell")
        detailTableView.register(txtFieldCellNib, forCellReuseIdentifier: "EditProfileTextFieldsTableViewCell")
        detailTableView.register(doneButtonCellNib, forCellReuseIdentifier: "EditProfileSaveButtonTableViewCell")
        
        textFieldPlaceholders = ["", "Short Bio", "Hobby", "Country", "Zip Code"]
        textFieldImages = ["", "username-1", "hobby", "country", "zip-code"]
        
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @objc func textFieldTextChanged(_ sender: UITextField){
        if (sender.tag == 1){
            shortBio = sender.text!
        }
        else if (sender.tag == 2){
            hobby = sender.text!
        }
        else if (sender.tag == 3){
            userCountry = sender.text!
        }
        else if (sender.tag == 4){
            zipCode = sender.text!
        }
    }
    
    func signupUserWithRequest(){
        
        let params = ["first_name": userModel.userFirstName,
                      "last_name": userModel.userLastName,
                      "date_of_birth": userModel.userDOB,
                      "username": userModel.username,
                      "gender": userModel.userGender,
                      "short_bio": shortBio,
                      "hobby": hobby,
                      "country": userCountry,
                      "zip_code": zipCode,
                      "email": userModel.userEmail,
                      "password": userModel.userPassword]
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .signup, method: .post, params: params, imageData: userImage.jpegData(compressionQuality: 0.5)) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        realm.deleteAll()
                        let model = UserModel()
                        model.updateModelWithJSON(json: result["user"])
                        realm.add(model)
                    }
                    let vc = Utility.getTabBarViewController()
                    self.present(vc, animated: true, completion: nil)
                }
                else{
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                
            }
        }
        
    }
    
}

extension SignupDetail2ViewController: UITableViewDataSource, UITableViewDelegate, EditProfileDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImageTableViewCell", for: indexPath) as! EditProfileImageTableViewCell
            cell.btnCamera.isHidden = true
            cell.userImage.isHidden = true
            cell.doneIcon.isHidden = false
            return cell
        }
        else if (indexPath.row == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileSaveButtonTableViewCell", for: indexPath) as! EditProfileSaveButtonTableViewCell
            // cell.btnDone.backgroundColor = .clear
            cell.btnDone.setTitle("Next", for: .normal)
            cell.delegate = self
            //   cell.btnDone.setImage(UIImage(named: "nextButton"), for: .normal)
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTextFieldsTableViewCell", for: indexPath) as! EditProfileTextFieldsTableViewCell
            Utility.setTextFieldPlaceholder(textField: cell.txtField, placeholder: textFieldPlaceholders[indexPath.row], color: Theme.editProfileTextFieldColor)
            cell.icon.image = UIImage(named: textFieldImages[indexPath.row])
            cell.txtField.tag = indexPath.row
            cell.txtField.delegate = self
            cell.txtField.autocapitalizationType = .sentences
            cell.txtField.keyboardType = indexPath.row == 4 ? .numberPad : .default
            cell.txtField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
            cell.txtField.text = indexPath.row == 3 ? userCountry : cell.txtField.text!
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0){
            return 220
        }
        else if (indexPath.row == 5){
            return 130
        }
        return 60
    }
    
    func btnDoneTapped() {
        signupUserWithRequest()
    }
    
}

extension SignupDetail2ViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.tag == 3){
            textField.endEditing(true)
            textField.resignFirstResponder()
            let countryPicker = CountryPickerWithSectionViewController.presentController(on: self) { (country) in
                self.userCountry = country.countryName
                self.detailTableView.reloadData()
            }
            countryPicker.isCountryDialHidden = true
            countryPicker.flagStyle = .circular
            self.view.endEditing(true)
            textField.endEditing(true)
        }
        
    }
}
