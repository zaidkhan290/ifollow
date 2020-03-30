//
//  EditProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import SDWebImage
import Loaf
import RealmSwift
import SKCountryPicker

class EditProfileViewController: UIViewController {

    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editProfileTableView: UITableView!
    var imagePicker = UIImagePickerController()
    var userImage = UIImage()
    var isImageUpdated = false
    
    var textFieldPlaceholders = [String]()
    var textFieldImages = [String]()
    var selectedDate = ""
    var dobDatePicker = UIDatePicker()
    
    var firstName = ""
    var lastName = ""
    var dob = ""
    var username = ""
    var userGender = ""
    var shortBio = ""
    var hobby = ""
    var userCountry = ""
    var zipCode = ""
    var userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editView.roundTopCorners(radius: 30)
        
        let imageCellNib = UINib(nibName: "EditProfileImageTableViewCell", bundle: nil)
        let txtFieldCellNib = UINib(nibName: "EditProfileTextFieldsTableViewCell", bundle: nil)
        let genderCellNib = UINib(nibName: "EditProfileGenderTableViewCell", bundle: nil)
        let doneButtonCellNib = UINib(nibName: "EditProfileSaveButtonTableViewCell", bundle: nil)
        
        editProfileTableView.register(imageCellNib, forCellReuseIdentifier: "EditProfileImageTableViewCell")
        editProfileTableView.register(txtFieldCellNib, forCellReuseIdentifier: "EditProfileTextFieldsTableViewCell")
        editProfileTableView.register(genderCellNib, forCellReuseIdentifier: "EditProfileGenderTableViewCell")
        editProfileTableView.register(doneButtonCellNib, forCellReuseIdentifier: "EditProfileSaveButtonTableViewCell")
        
        textFieldPlaceholders = ["", "First Name", "Last Name", "mm/dd/yy", "Username", "", "Short Bio", "Hobby", "Country", "Zip Code"]
        textFieldImages = ["", "username-1", "username-1", "calendar", "username-1", "", "username-1", "hobby", "country", "zip-code"]
        
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image" /*"public.movie"*/]
        imagePicker.delegate = self
        
        dobDatePicker.datePickerMode = .date
        userModel = UserModel.getCurrentUser()!
        userGender = userModel.userGender
        firstName = userModel.userFirstName
        lastName = userModel.userLastName
        dob = userModel.userDOB
        username = userModel.username
        shortBio = userModel.userShortBio
        hobby = userModel.userHobby
        userCountry = userModel.userCountry
        zipCode = userModel.userZipCode
        
    }
   
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textfieldDidBeginEditing(_ sender: UITextField){
        if (sender.tag == 3){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            selectedDate = dateFormatter.string(from: dobDatePicker.date)
            let cell = self.editProfileTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! EditProfileTextFieldsTableViewCell
            cell.txtField.text = selectedDate
            dob = selectedDate
            dobDatePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        }
    }
    
    @objc func handleDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        selectedDate = dateFormatter.string(from: dobDatePicker.date)
        let cell = self.editProfileTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! EditProfileTextFieldsTableViewCell
        cell.txtField.text = selectedDate
        dob = selectedDate
    }
    
    @objc func textFieldTextChanged(_ sender: UITextField){
        if (sender.tag == 1){
            firstName = sender.text!
        }
        else if (sender.tag == 2){
            lastName = sender.text!
        }
        else if (sender.tag == 3){
            dob = sender.text!
        }
        else if (sender.tag == 4){
            username = sender.text!
        }
        else if (sender.tag == 8){
            userCountry = sender.text!
        }
        else if (sender.tag == 9){
            zipCode = sender.text!
        }
    }
    
    func openImagePicker(){
        
        let alertVC = UIAlertController(title: "Select Action", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func updateImageWithRequest(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .updateProfilePicture, method: .post, params: nil, imageData: userImage.jpegData(compressionQuality: 0.5)) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        if let user = UserModel.getCurrentUser(){
                            user.userImage = result["image"].stringValue.replacingOccurrences(of: "\\", with: "")
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
    
    func updateUserProfileWithRequest(){
        
        let params = ["first_name": firstName,
                      "last_name": lastName,
                      "date_of_birth": dob,
                      "username": username,
                      "gender": userGender,
                      "short_bio": shortBio,
                      "hobby": hobby,
                      "country": userCountry,
                      "zip_code": zipCode,
                      "email": userModel.userEmail]
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .updateProfile, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        if let user = UserModel.getCurrentUser(){
                            user.userFirstName = self.firstName
                            user.userLastName = self.lastName
                            user.userDOB = self.dob
                            user.username = self.username
                            user.userGender = self.userGender
                            user.userShortBio = self.shortBio
                            user.userHobby = self.hobby
                            user.userCountry = self.userCountry
                            user.userZipCode = self.zipCode
                        }
                    }
                    
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
}

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImageTableViewCell", for: indexPath) as! EditProfileImageTableViewCell
            
            if (isImageUpdated){
                cell.userImage.image = userImage
            }
            else{
               cell.userImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
            }
            cell.userImage.layer.cornerRadius = cell.userImage.bounds.height / 2
            return cell
        }
        else if (indexPath.row == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileGenderTableViewCell", for: indexPath) as! EditProfileGenderTableViewCell
            cell.delegate = self
            
            if (userGender == ""){
                cell.manImage.layer.borderColor = UIColor.clear.cgColor
                cell.girlImage.layer.borderColor = UIColor.clear.cgColor
            }
            else if (userGender == "male"){
                cell.manImage.layer.borderColor = UIColor.black.cgColor
                cell.girlImage.layer.borderColor = UIColor.clear.cgColor
            }
            else{
                cell.girlImage.layer.borderColor = UIColor.black.cgColor
                cell.manImage.layer.borderColor = UIColor.clear.cgColor
            }
            return cell
        }
        else if (indexPath.row == 10){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileSaveButtonTableViewCell", for: indexPath) as! EditProfileSaveButtonTableViewCell
            cell.delegate = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTextFieldsTableViewCell", for: indexPath) as! EditProfileTextFieldsTableViewCell
            Utility.setTextFieldPlaceholder(textField: cell.txtField, placeholder: textFieldPlaceholders[indexPath.row], color: Theme.editProfileTextFieldColor)
            cell.icon.image = UIImage(named: textFieldImages[indexPath.row])
            cell.txtField.tag = indexPath.row
            cell.txtField.delegate = self
            cell.txtView.tag = indexPath.row
            cell.txtField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
            cell.txtView.delegate = self
            cell.txtView.layer.borderWidth = 0.5
            cell.txtView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            
            if (indexPath.row == 1){
                cell.txtField.text = firstName
                cell.txtField.keyboardType = .default
                cell.txtField.autocapitalizationType = .words
                cell.txtField.isHidden = false
                cell.seperatorView.isHidden = false
                cell.txtView.isHidden = true
                cell.txtViewSeperator.isHidden = true
                cell.lblHeading.isHidden = true
                cell.requiredIcon.isHidden = false
            }
            else if (indexPath.row == 2){
                cell.txtField.text = lastName
                cell.txtField.keyboardType = .default
                cell.txtField.autocapitalizationType = .words
                cell.txtField.isHidden = false
                cell.seperatorView.isHidden = false
                cell.txtView.isHidden = true
                cell.txtViewSeperator.isHidden = true
                cell.lblHeading.isHidden = true
                cell.requiredIcon.isHidden = false
            }
            else if (indexPath.row == 3){
                cell.txtField.text = dob
                cell.txtField.inputView = dobDatePicker
                cell.txtField.addTarget(self, action: #selector(textfieldDidBeginEditing(_:)), for: .editingDidBegin)
                cell.txtField.isHidden = false
                cell.seperatorView.isHidden = false
                cell.txtView.isHidden = true
                cell.txtViewSeperator.isHidden = true
                cell.lblHeading.isHidden = true
                cell.requiredIcon.isHidden = true
            }
            else if (indexPath.row == 4){
                cell.txtField.text = username
                cell.txtField.keyboardType = .default
                cell.txtField.autocapitalizationType = .none
                cell.txtField.isHidden = false
                cell.seperatorView.isHidden = false
                cell.txtView.isHidden = true
                cell.txtViewSeperator.isHidden = true
                cell.lblHeading.isHidden = true
                cell.requiredIcon.isHidden = false
            }
            else if (indexPath.row == 6){
                cell.txtView.text = shortBio
                cell.txtView.keyboardType = .default
                cell.txtView.autocapitalizationType = .sentences
                cell.txtField.isHidden = true
                cell.seperatorView.isHidden = true
                cell.txtView.isHidden = false
                cell.txtViewSeperator.isHidden = false
                cell.lblHeading.isHidden = false
                cell.requiredIcon.isHidden = true
                cell.lblHeading.text = "Tell us something about yourself"
            }
            else if (indexPath.row == 7){
                cell.txtView.text = hobby
                cell.txtView.keyboardType = .default
                cell.txtView.autocapitalizationType = .sentences
                cell.txtField.isHidden = true
                cell.seperatorView.isHidden = true
                cell.txtView.isHidden = false
                cell.txtViewSeperator.isHidden = false
                cell.lblHeading.isHidden = false
                cell.requiredIcon.isHidden = true
                cell.lblHeading.text = "Tell us some of your hobbies"
            }
            else if (indexPath.row == 8){
                cell.txtField.text = userCountry
                cell.txtField.keyboardType = .default
                cell.txtField.autocapitalizationType = .words
                cell.txtField.isHidden = false
                cell.seperatorView.isHidden = false
                cell.txtView.isHidden = true
                cell.txtViewSeperator.isHidden = true
                cell.lblHeading.isHidden = true
                cell.requiredIcon.isHidden = true
            }
            else if (indexPath.row == 9){
                cell.txtField.text = zipCode
                cell.txtField.keyboardType = .numberPad
                cell.txtField.autocapitalizationType = .none
                cell.txtField.isHidden = false
                cell.seperatorView.isHidden = false
                cell.txtView.isHidden = true
                cell.txtViewSeperator.isHidden = true
                cell.lblHeading.isHidden = true
                cell.requiredIcon.isHidden = true
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            openImagePicker()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0){
            return 150
        }
        else if (indexPath.row == 5){
            return 70
        }
        else if (indexPath.row == 6 || indexPath.row == 7){
            return 133
        }
        else if (indexPath.row == 11){
            return 80
        }
        return 60
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            userImage = pickedImage
            isImageUpdated = true
            self.editProfileTableView.reloadData()
            self.updateImageWithRequest()
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension EditProfileViewController: EditProfileDelegate{
    func btnDoneTapped() {
        
        if (firstName == ""){
            Loaf(kFirstNameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (lastName == ""){
            Loaf(kLastNameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        else if (username == ""){
            Loaf(kUsernameError, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
            return
        }
        
        updateUserProfileWithRequest()
        
    }
}

extension EditProfileViewController: EditProfileGenderTableViewCellDelegate{
    func genderTapped(gender: String) {
        userGender = gender
    }
}

extension EditProfileViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.tag == 8){
            textField.endEditing(true)
            textField.resignFirstResponder()
            let countryPicker = CountryPickerWithSectionViewController.presentController(on: self) { (country) in
                self.userCountry = country.countryName
                self.editProfileTableView.reloadData()
            }
            countryPicker.isCountryDialHidden = true
            countryPicker.flagStyle = .circular
            self.view.endEditing(true)
            textField.endEditing(true)
        }
        
    }
}

extension EditProfileViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if (textView.tag == 6){
            shortBio = textView.text!
        }
        else if (textView.tag == 7){
            hobby = textView.text!
        }
    }
}
