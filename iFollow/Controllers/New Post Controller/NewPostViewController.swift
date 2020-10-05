//
//  NewPostViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 11/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
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

protocol PostViewControllerDelegate: class {
    func postTapped(postView: UIViewController)
    func imageTapped(postView: UIViewController)
}

class NewPostViewController: UIViewController {

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var txtViewStatus: HKWTextView!
    @IBOutlet weak var txtFieldStatus: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var btnPic: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnBoost: UIButton!
    @IBOutlet weak var btnPostBackgroundImage: UIImageView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var postViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblTotalBudget: UILabel!
    @IBOutlet weak var txtFieldLink: UITextField!
    @IBOutlet weak var linkSwitch: UISwitch!
    @IBOutlet weak var btnBoostPost: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var lblBoostYourPost: UILabel!
    @IBOutlet weak var lblPublicComment: UILabel!
    @IBOutlet weak var publicCommentSwitch: UISwitch!
    
    var storageRef: StorageReference?
    var isDetail = false
    var postSelectedImage = UIImage()
    var isVideo = false
    var videoURL: URL!
    var delegate: PostViewControllerDelegate!
    var days = 1
    var userAddress = ""
    var budget: Float = 0.0
    var totalBudget: Float = 0.0
    var isForEdit = false
    var editablePostId = 0
    var editablePostText = ""
    var editablePostImage = ""
    var editablePostMediaType = ""
    var editablePostUserLocation = ""
    var isValidURL = false
    var isForBoostEdit = false
    var editablePostStatus = ""
    var editablePostLink = ""
    var braintreeClient: BTAPIClient!
    var paymentId = ""
    var tagUserIds = [Int]()
    
    @IBOutlet weak var txtFieldLinkTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupColors()
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        setTotalBudget()
        
        postView.layer.cornerRadius = 20
        btnBoost.isHidden = isForEdit
        btnPic.isHidden = isForEdit
        lblPublicComment.isHidden = isForEdit
        publicCommentSwitch.isHidden = isForEdit
        if (isForEdit){
            txtFieldStatus.text = editablePostText
            if (editablePostMediaType == "image"){
                postImage.sd_setImage(with: URL(string: editablePostImage))
            }
            else{
                postImage.image = UIImage(named: "post_video")
            }
        }
        else{
            postImage.image = postSelectedImage
        }
        
        lblDays.text = "\(days) Days"
        
        postImage.isUserInteractionEnabled = !isForEdit
        postImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postImageTapped)))
        postView.addShadow()
        txtFieldStatus.delegate = self
        txtFieldLink.delegate = self
        self.braintreeClient = BTAPIClient(authorization: BT_AUTHORIZATION_KEY)
        
        if (isForBoostEdit){
            postViewTopConstraint.constant = 70
            postViewHeightConstraint.constant = 357
            txtFieldLinkTopConstraint.constant = 10
            self.postView.layer.cornerRadius = 20
            seperatorView.isHidden = true
            lblBoostYourPost.isHidden = true
            if (editablePostStatus == "boost"){
                linkSwitch.isOn = editablePostLink != ""
                txtFieldLink.text = editablePostLink
                txtFieldLink.isHidden = editablePostLink == ""
                isValidURL = editablePostLink != ""
            }
            self.view.updateConstraintsIfNeeded()
            self.view.layoutSubviews()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            if (self.paymentId != ""){
                self.getPaymentStatus()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton) {
        if (!isForEdit){
            if (delegate != nil){
                self.delegate.imageTapped(postView: self)
            }
        }
        
    }
    
    @IBAction func btnLocationTapped(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func setupColors(){
        self.postView.setColor()
        postView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
    }
    
    @objc func budgetSliderValueChange(){
//        budget = budgetSlider.value.rounded()
//        let budgetString = String(format: "%.0f", budget)
//        lblAddBudget.text = "Daily Budget ($\(budgetString))"
//        setTotalBudget()
    }
    
    @objc func setTotalBudget(){
        totalBudget = budget * Float(days)
        let budgetString = String(format: "%.0f", totalBudget)
        lblTotalBudget.text = "$\(budgetString)"
    }
    
    @IBAction func btnBoostTapped(_ sender: UIButton) {
        if (!isForEdit){
            changePostViewSize()
        }
    }
    
    @IBAction func btnPostTapped(_ sender: UIButton){
        if (isForEdit){
            
            if (editablePostStatus == "boost"){
                if (linkSwitch.isOn){
                    if (isValidURL){
                        editPostWithRequest()
                    }
                    else{
                        Loaf("Please enter the valid URL", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            
                        }
                    }
                }
                else{
                    isValidURL = false
                    editPostWithRequest()
                }
            }
            else{
               self.editPostWithRequest()
            }
            
        }
        else{
            self.savePostMediaToFirebase(image: postSelectedImage)
        }
        
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        if (days > 1){
            days -= 1
        }
        lblDays.text = "\(days) Days"
        setTotalBudget()
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        if (days >= 1){
            days += 1
        }
        lblDays.text = "\(days) Days"
        setTotalBudget()
    }
    
    @IBAction func linkSwitchTapped(_ sender: UISwitch) {
        txtFieldLink.isHidden = !sender.isOn
    }
    
    @IBAction func btnBoosPostTapped(_ sender: UIButton) {
        if (linkSwitch.isOn){
            if (isValidURL){
                showPaypalPopup()
            }
            else{
                Loaf("Please enter the valid URL", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    
                }
            }
        }
        else{
            isValidURL = false
            showPaypalPopup()
        }
        
    }
    
    func showPaypalPopup(){
        let alertVC = UIAlertController(title: "Caution", message: "Please do not close iFollow during payment process.", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (action) in
            DispatchQueue.main.async {
                self.payWithPaypal()
            }
        }
        alertVC.addAction(continueAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func payWithPaypal(){
        self.isDetail = true
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["amount": totalBudget]
        
        API.sharedInstance.executeAPI(type: .payWithPaypal, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.paymentId = result["payment_id"].stringValue
                    let paymentUrl = result["data"].stringValue
                    if UIApplication.shared.canOpenURL(URL(string: paymentUrl)!){
                        UIApplication.shared.open(URL(string: paymentUrl)!)
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
    
    func getPaymentStatus(){
         
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["payment_id": paymentId]
        
        API.sharedInstance.executeAPI(type: .getPaymentStatus, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.savePostMediaToFirebase(image: self.postSelectedImage)
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
    
//    func payWithPaypal(){
//        self.isDetail = true
//        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
//        payPalDriver.viewControllerPresentingDelegate = self
//        payPalDriver.appSwitchDelegate = self
//
//        let request = BTPayPalRequest(amount: "\(totalBudget)")
//        request.currencyCode = "USD"
//        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) -> Void in
//            guard let tokenizedPayPalAccount = tokenizedPayPalAccount else {
//                if let error = error {
//                    Loaf(error.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
//
//                    }
//                } else {
//                    // User canceled
//                }
//                return
//            }
//         //   print("Got a nonce! \(tokenizedPayPalAccount.nonce)")
//            Loaf("Payment Success", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
//
//            }
//            self.savePostMediaToFirebase(image: self.postSelectedImage)
//        }
//    }
    
    @objc func postImageTapped(){
        if (isVideo){
            let player = AVPlayer(url: videoURL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    func changePostViewSize(){
        
        isDetail = !isDetail
        btnPost.isHidden = isDetail
        btnPostBackgroundImage.isHidden = isDetail
        
        if (isDetail){
            postViewTopConstraint.constant = 50
            postViewHeightConstraint.constant = 550
        }
        else{
            postViewTopConstraint.constant = 100
            postViewHeightConstraint.constant = 300
        }
        self.postView.layer.cornerRadius = 20
        self.view.updateConstraintsIfNeeded()
        self.view.layoutSubviews()
        
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
                                if (self.isDetail){
                                    params = ["media": videoURL.absoluteString,
                                              "description": self.txtFieldStatus.text!,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": self.days,
                                              "public_comments": self.publicCommentSwitch.isOn ? 1 : 0,
                                              "media_type": "video",
                                              "budget": self.budget,
                                              "tags": self.tagUserIds,
                                              "original_id": Utility.getLoginUserId(),
                                              "original_name": Utility.getLoginUserFullName(),
                                              "link": self.isValidURL ? self.txtFieldLink.text! : ""] as [String: Any]
                                }
                                else{
                                    params = ["media": videoURL.absoluteString,
                                              "description": self.txtFieldStatus.text!,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": 0,
                                              "public_comments": self.publicCommentSwitch.isOn ? 1 : 0,
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
                                if (self.isDetail){
                                    params = ["media": imageURL.absoluteString,
                                              "description": self.txtFieldStatus.text!,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": self.days,
                                              "public_comments": self.publicCommentSwitch.isOn ? 1 : 0,
                                              "media_type": "image",
                                              "tags": self.tagUserIds,
                                              "original_id": Utility.getLoginUserId(),
                                              "original_name": Utility.getLoginUserFullName(),
                                              "budget": self.budget,
                                              "link": self.isValidURL ? self.txtFieldLink.text! : ""] as [String: Any]
                                }
                                else{
                                    params = ["media": imageURL.absoluteString,
                                              "description": self.txtFieldStatus.text!,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": 0,
                                              "public_comments": self.publicCommentSwitch.isOn ? 1 : 0,
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
                        self.delegate.postTapped(postView: self)
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
                      "location": self.userAddress == "" ? self.editablePostUserLocation : self.userAddress,
                      "description": txtFieldStatus.text!,
                      "link": isValidURL ? self.txtFieldLink.text! : ""] as [String : Any]
        }
        else{
            params = ["post_id": editablePostId,
                      "location": self.userAddress == "" ? self.editablePostUserLocation : self.userAddress,
                      "description": txtFieldStatus.text!] as [String : Any]
        }
        
        API.sharedInstance.executeAPI(type: .editPost, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.delegate.postTapped(postView: self)
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
    
    func displayDefaultAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkIsValidURL(){
        txtFieldLink.endEditing(true)
        if (txtFieldLink.text!.isValidURL){
            isValidURL = true
        }
        else{
            isValidURL = false
            Loaf("Please enter the valid URL", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
    }
}

extension NewPostViewController: GMSAutocompleteViewControllerDelegate{
    
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

extension NewPostViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == txtFieldStatus){
            IQKeyboardManager.shared.enableAutoToolbar = true
        }
        else if (textField == txtFieldLink){
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == txtFieldStatus){
            if (isVideo){
                let maxLength = 40
                let currentString: NSString = textField.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            }
            else{
                return true
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtFieldLink){
            checkIsValidURL()
        }
        return true
    }
    

}

extension NewPostViewController: PKPaymentAuthorizationViewControllerDelegate{
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        dismiss(animated: true, completion: nil)
        displayDefaultAlert(title: "Success!", message: "The Apple Pay transaction was complete.")
    }
    
}

extension NewPostViewController: BTAppSwitchDelegate, BTViewControllerPresentingDelegate{
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
    
}
