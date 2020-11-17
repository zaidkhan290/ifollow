//
//  CreatePost2ViewController.swift
//  iFollow
//
//  Created by BSQP on 16/11/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import GooglePlaces
import FirebaseStorage
import Loaf
import AVFoundation
import AVKit
import PassKit
import IQKeyboardManagerSwift
import Braintree
import Hakawai

class CreatePost2ViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var btnTag: UIButton!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var feedbackSwitch: UISwitch!
    @IBOutlet weak var boostView: UIView!
    @IBOutlet weak var boostSwitch: UISwitch!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var totalBudgetView: UIView!
    @IBOutlet weak var lblTotalBudget: UILabel!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var txtfieldLink: UITextField!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btnViewTopConstraint: NSLayoutConstraint!
    
    var storageRef: StorageReference?
    var userAddress = ""
    var isStatusPost = false
    var postCaption = ""
    var isVideo = false
    var videoURL: URL!
    var postSelectedImage = UIImage()
    var budget: Float = 0.0
    var totalBudget: Float = 0.0
    var tagUserIds = [Int]()
    var days = 1
    var isValidURL = false
    
    var isForEdit = false
    var editablePostId = 0
    var editablePostText = ""
    var editablePostImage = ""
    var editablePostMediaType = ""
    var editablePostUserLocation = ""
    var isForBoostEdit = false
    var editablePostStatus = ""
    var editablePostLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    //MARK:- Methods and Actions
    
    func setColors(){
        self.view.setColor()
        btnBack.setImage(UIImage(named: traitCollection.userInterfaceStyle == .dark ? "back" : "ArrowleftBlack"), for: .normal)
        btnPost.setImage(UIImage(named: traitCollection.userInterfaceStyle == .dark ? "post_white" : "post_black"), for: .normal)
    }
    
    func setData(){
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        self.locationView.isUserInteractionEnabled = true
        self.locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(locationViewTapped)))
        lblDuration.text = "\(days) Days"
        txtfieldLink.delegate = self
        lblTag.text = tagUserIds.count == 0 ? "0 Person" : "\(tagUserIds.count) Persons"
        setTotalBudget()
        
        if (isForEdit){
            lblTopTitle.text = "Edit Post"
            lblLocation.text = editablePostUserLocation
            btnViewTopConstraint.constant = -198
            mainViewHeightConstraint.constant = 210
            tagView.isHidden = true
            feedBackView.isHidden = true
            boostView.isHidden = true
            self.view.updateConstraintsIfNeeded()
            self.view.layoutSubviews()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(proceedAfterPayment), name: NSNotification.Name(rawValue: "proceedAfterStripe"), object: nil)
    }
    
    func changeViewSize(){
        mainViewHeightConstraint.constant = boostSwitch.isOn ? 540 : 350
        durationView.isHidden = !boostSwitch.isOn
        totalBudgetView.isHidden = !boostSwitch.isOn
        linkView.isHidden = !boostSwitch.isOn
        btnViewTopConstraint.constant = boostSwitch.isOn ? 198 : 0
        self.view.updateConstraintsIfNeeded()
        self.view.layoutSubviews()
    }
    
    @objc func locationViewTapped(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.modalPresentationStyle = .fullScreen
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }

    @objc func setTotalBudget(){
        totalBudget = budget * Float(days)
        let budgetString = String(format: "%.0f", totalBudget)
        lblTotalBudget.text = "$\(budgetString)"
    }
    
    func checkIsValidURL(){
        txtfieldLink.endEditing(true)
        if (txtfieldLink.text!.isValidURL){
            isValidURL = true
        }
        else{
            isValidURL = false
            txtfieldLink.text = ""
            Loaf("Please enter the valid URL", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
        }
    }
    
    func payWithStripe(){
        let vc = Utility.getStripeCheckoutController()
        vc.totalAmount = totalBudget
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func proceedAfterPayment(){
        if (isStatusPost){
            self.addStatusPost()
        }
        else{
            self.savePostMediaToFirebase(image: self.postSelectedImage)
        }
    }
    
    func addStatusPost(){
        var params = [String: Any]()
        if (self.boostSwitch.isOn){
            params = ["media": "",
                      "description": self.postCaption,
                      "location": self.userAddress,
                      "expire_hours": Utility.getLoginUserPostExpireHours(),
                      "duration": self.days,
                      "public_comments": self.feedbackSwitch.isOn ? 1 : 0,
                      "media_type": "text",
                      "budget": self.budget,
                      "tags": self.tagUserIds,
                      "original_id": Utility.getLoginUserId(),
                      "original_name": Utility.getLoginUserFullName(),
                      "link": self.isValidURL ? self.txtfieldLink.text! : ""] as [String: Any]
        }
        else{
            params = ["media": "",
                      "description": self.postCaption,
                      "location": self.userAddress,
                      "expire_hours": Utility.getLoginUserPostExpireHours(),
                      "duration": 0,
                      "public_comments": self.feedbackSwitch.isOn ? 1 : 0,
                      "media_type": "video",
                      "tags": self.tagUserIds,
                      "original_id": Utility.getLoginUserId(),
                      "original_name": Utility.getLoginUserFullName(),
                      "budget": 0] as [String: Any]
        }
        Utility.showOrHideLoader(shouldShow: true)
        self.addPostWithRequest(params: params)
    }
    
    func savePostMediaToFirebase(image: UIImage){
        
        if (isVideo){
            let timeStemp = Int(Date().timeIntervalSince1970)
            let mediaRef = storageRef?.child("/Media")
            let iosRef = mediaRef?.child("/iOS").child("/Videos")
            let videoRef = iosRef?.child("/PostVideo\(timeStemp).mov")
            
            if let videoData = try? Data(contentsOf: videoURL){
                
                Utility.showOrHideLoader(shouldShow: true)
                
                let uploadTask = videoRef?.putData(videoData, metadata: nil, completion: { (metaData, error) in
                    if(error != nil){
                        Utility.showOrHideLoader(shouldShow: false)
                        Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                            
                        }
                    }else{
                        
                        videoRef?.downloadURL(completion: { (url, error) in
                            if let videoURL = url{
                                var params = [String: Any]()
                                if (self.boostSwitch.isOn){
                                    params = ["media": videoURL.absoluteString,
                                              "description": self.postCaption,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": self.days,
                                              "public_comments": self.feedbackSwitch.isOn ? 1 : 0,
                                              "media_type": "video",
                                              "budget": self.budget,
                                              "tags": self.tagUserIds,
                                              "original_id": Utility.getLoginUserId(),
                                              "original_name": Utility.getLoginUserFullName(),
                                              "link": self.isValidURL ? self.txtfieldLink.text! : ""] as [String: Any]
                                }
                                else{
                                    params = ["media": videoURL.absoluteString,
                                              "description": self.postCaption,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": 0,
                                              "public_comments": self.feedbackSwitch.isOn ? 1 : 0,
                                              "media_type": "video",
                                              "tags": self.tagUserIds,
                                              "original_id": Utility.getLoginUserId(),
                                              "original_name": Utility.getLoginUserFullName(),
                                              "budget": 0] as [String: Any]
                                }
                                self.addPostWithRequest(params: params)
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
        else{
            let timeStemp = Int(Date().timeIntervalSince1970)
            let mediaRef = storageRef?.child("/Media")
            let iosRef = mediaRef?.child("/iOS").child("/Images")
            let picRef = iosRef?.child("/PostImage\(timeStemp).jgp")
            
            //        let imageData2 = UIImagePNGRepresentation(image)
            if let imageData2 = image.jpegData(compressionQuality: 0.75) {
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
                                var params = [String: Any]()
                                if (self.boostSwitch.isOn){
                                    params = ["media": imageURL.absoluteString,
                                              "description": self.postCaption,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": self.days,
                                              "public_comments": self.feedbackSwitch.isOn ? 1 : 0,
                                              "media_type": "image",
                                              "tags": self.tagUserIds,
                                              "original_id": Utility.getLoginUserId(),
                                              "original_name": Utility.getLoginUserFullName(),
                                              "budget": self.budget,
                                              "link": self.isValidURL ? self.txtfieldLink.text! : ""] as [String: Any]
                                }
                                else{
                                    params = ["media": imageURL.absoluteString,
                                              "description": self.postCaption,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": 0,
                                              "public_comments": self.feedbackSwitch.isOn ? 1 : 0,
                                              "media_type": "image",
                                              "tags": self.tagUserIds,
                                              "original_id": Utility.getLoginUserId(),
                                              "original_name": Utility.getLoginUserFullName(),
                                              "budget": 0] as [String: Any]
                                }
                                self.addPostWithRequest(params: params)
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
        
    }
    
    func addPostWithRequest(params: [String: Any]){
        
        API.sharedInstance.executeAPI(type: .createPost, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserPostPostedSuccessfully"), object: nil)
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
    
    func editPostWithRequest(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        var params = [String:Any]()
        
        if (editablePostStatus == "boost"){
            params = ["post_id": editablePostId,
                      "location": self.lblLocation.text!,
                      "description": editablePostText,
                      "link": editablePostLink] as [String : Any]
        }
        else{
            params = ["post_id": editablePostId,
                      "location": lblLocation.text!,
                      "description": editablePostText] as [String : Any]
        }
        
        API.sharedInstance.executeAPI(type: .editPost, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserPostPostedSuccessfully"), object: nil)
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
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnTagTapped(_ sender: UIButton) {
        let vc = Utility.getAddMembersViewController()
        vc.delegate = self
        vc.isForTagging = true
        vc.selectedUsersIds = self.tagUserIds
        self.pushToVC(vc: vc)
    }
    
    @IBAction func boostSwitchedChanged(_ sender: UISwitch) {
        changeViewSize()
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        if (days > 1){
            days -= 1
        }
        lblDuration.text = "\(days) Days"
        setTotalBudget()
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        if (days >= 1){
            days += 1
        }
        lblDuration.text = "\(days) Days"
        setTotalBudget()
    }
    
    @IBAction func btnPostTapped(_ sender: UIButton) {
//        if (isForEdit){
//
//            if (editablePostStatus == "boost"){
//                if (linkSwitch.isOn){
//                    if (isValidURL){
//                        editPostWithRequest()
//                    }
//                    else{
//                        Loaf("Please enter the valid URL", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
//
//                        }
//                    }
//                }
//                else{
//                    isValidURL = false
//                    editPostWithRequest()
//                }
//            }
//            else{
//               self.editPostWithRequest()
//            }
//
//        }
//        else{
//            self.savePostMediaToFirebase(image: postSelectedImage)
//        }
        
        if (isForEdit){
            self.editPostWithRequest()
        }
        else{
            if (boostSwitch.isOn){
                payWithStripe()
            }
            else{
                if (isStatusPost){
                    self.addStatusPost()
                }
                else{
                    self.savePostMediaToFirebase(image: self.postSelectedImage)
                }
                
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
    
}

extension CreatePost2ViewController: GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let placeName = place.name{
            userAddress = placeName
            lblLocation.text = userAddress
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreatePost2ViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == txtfieldLink){
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtfieldLink){
            checkIsValidURL()
        }
        return true
    }
}

extension CreatePost2ViewController: AddMembersViewControllerDelegate{
    
    func membersAdded(membersArray: [PostLikesUserModel]) {
        
        tagUserIds = membersArray.map{$0.userId}
        lblTag.text = tagUserIds.count == 0 ? "0 Person" : "\(tagUserIds.count) Persons"
        
    }
    
}
