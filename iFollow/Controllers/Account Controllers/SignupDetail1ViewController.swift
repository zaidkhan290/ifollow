//
//  SignupDetail1ViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class SignupDetail1ViewController: UIViewController {

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTableView: UITableView!
    
    var textFieldPlaceholders = [String]()
    var textFieldImages = [String]()
    var imagePicker = UIImagePickerController()
    var userImage = UIImage()
    var selectedDate = ""
    
    var firstName = ""
    var lastName = ""
    var dob = ""
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailView.roundTopCorners(radius: 30)
        
        let imageCellNib = UINib(nibName: "EditProfileImageTableViewCell", bundle: nil)
        let txtFieldCellNib = UINib(nibName: "EditProfileTextFieldsTableViewCell", bundle: nil)
        let genderCellNib = UINib(nibName: "EditProfileGenderTableViewCell", bundle: nil)
        let doneButtonCellNib = UINib(nibName: "EditProfileSaveButtonTableViewCell", bundle: nil)
        
        detailTableView.register(imageCellNib, forCellReuseIdentifier: "EditProfileImageTableViewCell")
        detailTableView.register(txtFieldCellNib, forCellReuseIdentifier: "EditProfileTextFieldsTableViewCell")
        detailTableView.register(genderCellNib, forCellReuseIdentifier: "EditProfileGenderTableViewCell")
        detailTableView.register(doneButtonCellNib, forCellReuseIdentifier: "EditProfileSaveButtonTableViewCell")
        
        textFieldPlaceholders = ["", "First Name", "Last Name", "mm/dd/yy", "Username"]
        textFieldImages = ["", "username-1", "username-1", "calendar", "username-1"]
        
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image" /*"public.movie"*/]
        imagePicker.delegate = self
        
        userImage = UIImage(named: "editProfilePlaceholder")!
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        selectedDate = dateFormatter.string(from: sender.date)
        dob = selectedDate
        self.detailTableView.reloadData()
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
    }
}

extension SignupDetail1ViewController: UITableViewDataSource, UITableViewDelegate, EditProfileDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImageTableViewCell", for: indexPath) as! EditProfileImageTableViewCell
            cell.userImage.image = userImage
            cell.userImage.layer.cornerRadius = cell.userImage.bounds.height / 2
            return cell
        }
        else if (indexPath.row == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileGenderTableViewCell", for: indexPath) as! EditProfileGenderTableViewCell
            return cell
        }
        else if (indexPath.row == 6){
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
            cell.txtField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
            
            if (indexPath.row == 3){
                cell.txtField.text = selectedDate
                cell.txtField.keyboardType = .numberPad
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                cell.txtField.inputView = datePicker
                datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
            }
            else{
                cell.txtField.text = cell.txtField.text
                cell.txtField.keyboardType = .default
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
        else if (indexPath.row == 6){
            return 80
        }
        return 60
    }
    
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
        
        let vc = Utility.getSignupDetail2ViewController()
        self.pushToVC(vc: vc)
    }
}

extension SignupDetail1ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            userImage = pickedImage
            self.detailTableView.reloadData()
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
