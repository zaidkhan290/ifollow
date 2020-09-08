//
//  CreateGroupViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import FirebaseStorage

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var txtFieldGroupName: UITextField!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var lblMembers: UILabel!
    
    var imagePicker = UIImagePickerController()
    var isGroupNameEditable = false
    var membersArray = [PostLikesUserModel]()
    var storageRef: StorageReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupColors()
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        bottomView.layer.cornerRadius = 10
        groupImage.roundBottomCorners(radius: 20)
        notificationSwitch.isOn = false
        notificationSwitch.tintColor = Theme.profileLabelsYellowColor
        notificationSwitch.onTintColor = Theme.profileLabelsYellowColor
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        txtFieldGroupName.delegate = self
        lblDate.isHidden = true
        
    }
    
    func setupColors(){
        self.view.setColor()
        self.bottomView.setColor()
        bottomView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnCameraTapped(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func btnEditTapped(_ sender: UIButton) {
        
        isGroupNameEditable = !isGroupNameEditable
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        if isGroupNameEditable{
            txtFieldGroupName.becomeFirstResponder()
        }
        
    }
    
    @IBAction func btnAddTapped(_ sender: UIButton) {
        let vc = Utility.getAddMembersViewController()
        vc.delegate = self
        vc.selectedUsersIds = self.membersArray.map{$0.userId}
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnCreateTapped(_ sender: UIButton){
        if (txtFieldGroupName.text == "Name of the Group"){
            Loaf("Please enter group name", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
            return
        }
        else if (membersArray.count == 0){
            Loaf("Please add atleast 1 member", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
            return
        }
        uploadGroupImageToFirebase()
    }
    
    func uploadGroupImageToFirebase(){
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/GroupImage\(timeStemp).jgp")
        
        //        let imageData2 = UIImagePNGRepresentation(image)
        if let imageData2 = groupImage.image!.jpegData(compressionQuality: 0.75) {
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = picRef?.putData(imageData2, metadata: metadata, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    picRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
                            self.createGroupWithRequest(groupImage: imageURL.absoluteString)
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func createGroupWithRequest(groupImage: String){
        
        var groupMembersIds = [Int]()
        groupMembersIds = membersArray.map{$0.userId}
        groupMembersIds.append(Utility.getLoginUserId())
        
        let params = ["name": txtFieldGroupName.text!,
                      "image": groupImage,
                      "notification": notificationSwitch.isOn ? 0 : 1,
                      "member_ids": groupMembersIds] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .createGroup, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    let groupID = result["chat_room_id"].stringValue
                    self.sendPushNotification(groupId: groupID)
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(2)) { (handler) in
                        self.goBack()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshGroupsList"), object: nil)
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
    
    func sendPushNotification(groupId: String){
        let params = ["user_id": "",
                      "alert": "\(txtFieldGroupName.text!): \(Utility.getLoginUserFullName()) created a new group",
            "name": Utility.getLoginUserFullName(),
            "data": "\(txtFieldGroupName.text!): \(Utility.getLoginUserFullName()) created a new group",
            "tag": 11,
            "chat_room_id": groupId] as [String: Any]
        API.sharedInstance.executeAPI(type: .sendPushNotification, method: .post, params: params) { (status, result, message) in
            
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
    }
}

extension CreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            groupImage.clipsToBounds = true
            groupImage.contentMode = .scaleAspectFill
            groupImage.image = image
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension CreateGroupViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtFieldGroupName.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        isGroupNameEditable = false
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        txtFieldGroupName.text = txtFieldGroupName.text == "" ? "Name of the Group" : txtFieldGroupName.text!
        
    }
    
}

extension CreateGroupViewController: AddMembersViewControllerDelegate{
    func membersAdded(membersArray: [PostLikesUserModel]) {
        self.membersArray = membersArray
        if (self.membersArray.count == 0){
            lblMembers.text = "This group doesn't have any member yet"
        }
        else{
            if (self.membersArray.count <= 3){
                lblMembers.text = self.membersArray.map{$0.userFullName}.joined(separator: ", ")
              //  ([0,1,1,0].map{String($0)}).joined(separator: ",")
            }
            else{
                var membersString = ""
                var members = [PostLikesUserModel]()
                for i in 0..<3{
                    members.append(self.membersArray[i])
                }
                membersString = members.map{$0.userFullName}.joined(separator: ", ")
                let remainingCount = self.membersArray.count - 3
                if (remainingCount == 1){
                    membersString = membersString + " and \(remainingCount) other"
                }
                else{
                    membersString = membersString + " and \(remainingCount) others"
                }
                lblMembers.text = membersString
            }
        }
    }
}
