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

protocol PostViewControllerDelegate: class {
    func postTapped(postView: UIViewController)
    func imageTapped(postView: UIViewController)
}

class NewPostViewController: UIViewController {

    @IBOutlet weak var postView: UIView!
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
    @IBOutlet weak var lblAddBudget: UILabel!
    @IBOutlet weak var budgetSlider: UISlider!
    @IBOutlet weak var lblMinBudget: UILabel!
    @IBOutlet weak var lblMaxBudget: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblPeoples: UILabel!
    @IBOutlet weak var lblTotalBudget: UILabel!
    @IBOutlet weak var txtFieldLink: UITextField!
    @IBOutlet weak var linkSwitch: UISwitch!
    @IBOutlet weak var btnBoostPost: UIButton!
    
    var storageRef: StorageReference?
    var isDetail = false
    var postSelectedImage = UIImage()
    var isVideo = false
    var videoURL: URL!
    var delegate: PostViewControllerDelegate!
    var days = 1
    var userAddress = ""
    var budget: Float = 1.0
    var totalBudget: Float = 1.0
    var isForEdit = false
    var editablePostId = 0
    var editablePostText = ""
    var editablePostImage = ""
    var editablePostMediaType = ""
    var editablePostUserLocation = ""
    var isValidURL = false
    var braintreeClient: BTAPIClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        
        postView.layer.cornerRadius = 20
        //btnBoost.isHidden = true
        btnPic.isHidden = isForEdit
        postView.dropShadow(color: .white)
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
        
        let peopleText = "10k - 20k People will saw this post"
        let range1 = peopleText.range(of: "10k - 20k")
        let range2 = peopleText.range(of: "People will saw this post")
        
        let attributedPeopleString = NSMutableAttributedString(string: peopleText)
        attributedPeopleString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: Theme.getLatoBoldFontOfSize(size: 14)], range: peopleText.nsRange(from: range1!))
        attributedPeopleString.addAttributes([NSAttributedString.Key.foregroundColor: Theme.privateChatBoxTabsColor, NSAttributedString.Key.font: Theme.getLatoRegularFontOfSize(size: 14)], range: peopleText.nsRange(from: range2!))
        lblPeoples.attributedText = attributedPeopleString
      
        let likeText = "2k - 4k Average of likes for this post"
        let rang1 = likeText.range(of: "2k - 4k")
        let rang2 = likeText.range(of: "Average of likes for this post")
        
        let attributedLikeString = NSMutableAttributedString(string: likeText)
        attributedLikeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: Theme.getLatoBoldFontOfSize(size: 14)], range: likeText.nsRange(from: rang1!))
        attributedLikeString.addAttributes([NSAttributedString.Key.foregroundColor: Theme.privateChatBoxTabsColor, NSAttributedString.Key.font: Theme.getLatoRegularFontOfSize(size: 14)], range: likeText.nsRange(from: rang2!))
        
        let visaText = "Visa **7045"
        let visaRange1 = visaText.range(of: "Visa")
        let visaRange2 = visaText.range(of: "**7045")
        
        let attributedVisaString = NSMutableAttributedString(string: visaText)
        attributedVisaString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: Theme.getLatoBoldFontOfSize(size: 14)], range: visaText.nsRange(from: visaRange1!))
        attributedVisaString.addAttributes([NSAttributedString.Key.foregroundColor: Theme.privateChatBoxTabsColor, NSAttributedString.Key.font: Theme.getLatoRegularFontOfSize(size: 14)], range: visaText.nsRange(from: visaRange2!))
        
        lblDays.text = "\(days) Days"
        
        budgetSlider.minimumValue = 1
        budgetSlider.maximumValue = 500
        budgetSlider.value = 1
        lblAddBudget.text = "Daily Budget ($1)"
        budgetSlider.addTarget(self, action: #selector(budgetSliderValueChange), for: .valueChanged)
        
        postImage.isUserInteractionEnabled = !isForEdit
        postImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postImageTapped)))
        postView.addShadow()
        txtFieldStatus.delegate = self
        txtFieldLink.delegate = self
        self.braintreeClient = BTAPIClient(authorization: BT_AUTHORIZATION_KEY)
        
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
    
    @objc func budgetSliderValueChange(){
        budget = budgetSlider.value.rounded()
        let budgetString = String(format: "%.0f", budget)
        lblAddBudget.text = "Daily Budget ($\(budgetString))"
        setTotalBudget()
    }
    
    @objc func setTotalBudget(){
        totalBudget = budget * Float(days)
        lblTotalBudget.text = "$\(totalBudget)"
    }
    
    @IBAction func btnBoostTapped(_ sender: UIButton) {
        if (!isForEdit){
            changePostViewSize()
        }
    }
    
    @IBAction func btnPostTapped(_ sender: UIButton){
        if (isForEdit){
            self.editPostWithRequest()
        }
        else{
            self.savePostMediaToFirebase(image: postSelectedImage)
        }
        
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        if (days > 1 && days <= 3){
            days -= 1
        }
        lblDays.text = "\(days) Days"
        setTotalBudget()
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        if (days >= 1 && days < 3){
            days += 1
        }
        lblDays.text = "\(days) Days"
        setTotalBudget()
    }
    
    @IBAction func linkSwitchTapped(_ sender: UISwitch) {
        txtFieldLink.isHidden = !sender.isOn
    }
    
    @IBAction func btnBoosPostTapped(_ sender: UIButton) {
        payWithPaypal()
//        let request = PKPaymentRequest()
//        request.merchantIdentifier = "merchant.com.mou.iFollow"
//        request.supportedNetworks = [.visa, .masterCard]
//        request.merchantCapabilities = .capability3DS
//        request.countryCode = "US"
//        request.currencyCode = "USD"
//        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Boost Payment", amount: NSDecimalNumber(value: budget))]
//
//        if let controller = PKPaymentAuthorizationViewController(paymentRequest: request) {
//            controller.delegate = self
//            present(controller, animated: true, completion: nil)
//        }
        
    }
    
    func payWithPaypal(){
        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        
        let request = BTPayPalRequest(amount: "\(totalBudget)")
        request.currencyCode = "USD"
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) -> Void in
            guard let tokenizedPayPalAccount = tokenizedPayPalAccount else {
                if let error = error {
                    Loaf(error.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                } else {
                    // User canceled
                }
                return
            }
            print("Got a nonce! \(tokenizedPayPalAccount.nonce)")
            Loaf("Payment Success", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                
            }
            let params = ["gateway": "paypal",
                          "description": "One time payment",
                          "amount": "1",
                          "response": "email: \(tokenizedPayPalAccount.email!), nonce: \(tokenizedPayPalAccount.nonce)",
                          "order_id": tokenizedPayPalAccount.payerId!,
                          "fk_plan_id": Utility.getLoginUserId(),
            "status": "Complete"] as [String : Any]
         //   self.proceedPayment(params: params)
            
//            if let address = tokenizedPayPalAccount.billingAddress {
//                print("Billing address:\n\(address.streetAddress)\n\(address.extendedAddress)\n\(address.locality) \(address.region)\n\(address.postalCode) \(address.countryCodeAlpha2)")
//            }
        }
    }
    
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
            postViewTopConstraint.constant = 20
            postViewHeightConstraint.constant = 620
        }
        else{
            postViewTopConstraint.constant = 100
            postViewHeightConstraint.constant = 280
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
                                              "media_type": "video",
                                              "budget": self.budget] as [String: Any]
                                }
                                else{
                                    params = ["media": videoURL.absoluteString,
                                              "description": self.txtFieldStatus.text!,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": 0,
                                              "media_type": "video",
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
                                              "media_type": "image",
                                              "budget": self.budget] as [String: Any]
                                }
                                else{
                                    params = ["media": imageURL.absoluteString,
                                              "description": self.txtFieldStatus.text!,
                                              "location": self.userAddress,
                                              "expire_hours": Utility.getLoginUserPostExpireHours(),
                                              "duration": 0,
                                              "media_type": "image",
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
        let params = ["post_id": editablePostId,
                      "location": self.userAddress == "" ? self.editablePostUserLocation : self.userAddress,
                      "description": txtFieldStatus.text!] as [String : Any]
        
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
