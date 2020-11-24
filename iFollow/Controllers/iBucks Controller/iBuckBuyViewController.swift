//
//  iBuckBuyViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
import Loaf
import RealmSwift
import Stripe
import PassKit

class iBuckBuyViewController: UIViewController {
    
    @IBOutlet weak var txtFieldNumOfBucks: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var paymentId = ""
    
    var buyImages = ["buyIcon", "buyIcon" ,"buyIcon"]
    var buyTile = ["50 Coins", "100 Coins", "500 Coins"]
    var buyDesc = ["Silver", "Gold", "Platinium"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.tblView.register(UINib(nibName: "iBucksTableViewCell", bundle: nil), forCellReuseIdentifier: "iBucksTableViewCell")
        self.keyboardView.isHidden = true
        self.txtFieldNumOfBucks.inputAccessoryView = keyboardView
        self.txtFieldNumOfBucks.becomeFirstResponder()
        self.txtFieldNumOfBucks.addTarget(self, action: #selector(txtAmountChanged), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addiBuckInUserAccount), name: NSNotification.Name(rawValue: "proceedAfterStripe"), object: nil)
//        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
//            if (self.paymentId != ""){
//                self.getPaymentStatus()
//            }
//        }
    }
    
    //MARK:- Methods and Actions
    
    func setColors(){
        self.view.setColor()
        tblView.setColor()
        btnContinue.setiBuckViewsBackgroundColor()
        btnContinue.setiBuckButtonTextColor()
    }
    
    @objc func txtAmountChanged(){
        if (txtFieldNumOfBucks.text == ""){
            lblNote.text = ""
        }
        else{
            let amount = Float(txtFieldNumOfBucks.text!)! - 0.01
            lblNote.text = "Note:\nYou will be charged $\(String(format: "%.2f", amount)) from your payment account."
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
    
    func handleApplePayButtonTapped() {

        var iBucks = Float(txtFieldNumOfBucks.text!)!
        iBucks = iBucks - 0.01

        let merchantIdentifier = "merchant.com.mou.iFollow"
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "US", currency: "USD")

        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            // The final line should represent your company;
            // it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
            PKPaymentSummaryItem(label: "iFollow", amount: NSDecimalNumber(value: iBucks)),
        ]
        // ...continued in next step
        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
                // Present Apple Pay payment sheet
                applePayContext.presentApplePay(on: self)
            } else {
                // There is a problem with your Apple Pay configuration
        }
    }
    
    func openApplePay(){
        
        var iBucks = Float(txtFieldNumOfBucks.text!)!
        iBucks = iBucks - 0.01
        
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        let paymentItem = PKPaymentSummaryItem.init(label: "iBucks", amount: NSDecimalNumber(value: iBucks))
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            
            let request = PKPaymentRequest()
                request.currencyCode = "USD" // 1
                request.countryCode = "US" // 2
                request.merchantIdentifier = "merchant.com.mou.iFollow" // 3
                request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
                request.supportedNetworks = paymentNetworks // 5
                request.paymentSummaryItems = [paymentItem] // 6
            
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                Loaf("Unable to present Apple Pay authorization.", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

                }
                return
            }
                paymentVC.delegate = self
                self.present(paymentVC, animated: true, completion: nil)
            
        }
        else {
            Loaf("Your device does not support Apple Pay", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

            }
        }
        
    }
    
    func payWithStripe(){
        var iBucks = Float(txtFieldNumOfBucks.text!)!
        iBucks = iBucks - 0.01
        let vc = Utility.getStripeCheckoutController()
        vc.totalAmount = iBucks
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
    }

    func payWithPaypal(){
        
        Utility.showOrHideLoader(shouldShow: true)
        var iBucks = Float(txtFieldNumOfBucks.text!)!
        iBucks = iBucks - 0.01
        let params = ["amount": iBucks]

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
                    self.addiBuckInUserAccount()
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
    
    @objc func addiBuckInUserAccount(){
        
        if let noOfBucks = Int(txtFieldNumOfBucks.text!){
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let params = ["ibucks": noOfBucks]
            
            API.sharedInstance.executeAPI(type: .addBuck, method: .post, params: params) { (status, result, message) in
                
                DispatchQueue.main.async {
                    Utility.showOrHideLoader(shouldShow: false)
                    
                    if (status == .success){
                        
                        let realm = try! Realm()
                        try! realm.safeWrite {
                            if let model = UserModel.getCurrentUser(){
                                model.userBuck = model.userBuck + result["ibucks"].intValue
                            }
                        }
                        
                        Loaf("iBucks added in your account", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            self.navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton) {
        if (txtFieldNumOfBucks.text == ""){
            Loaf("Please enter number of iBucks", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

            }
            return
        }
        //showPaypalPopup()
      //  payWithStripe()
        if (Stripe.deviceSupportsApplePay()){
            handleApplePayButtonTapped()
        }
        else{
            Loaf("Your device does not support Apple Pay", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

            }
        }
       // addiBuckInUserAccount()
        
//        openApplePay()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
    
}

extension iBuckBuyViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.keyboardView.isHidden = true
    }
    
}

extension iBuckBuyViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iBucksTableViewCell", for: indexPath) as! iBucksTableViewCell
        cell.buyImageView.image = UIImage(named: buyImages[indexPath.row])
        cell.titleLbl.text = buyTile[indexPath.row]
        cell.descLbl.text = buyDesc[indexPath.row]
        cell.valueLbll.isHidden = false
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension iBuckBuyViewController: STPApplePayContextDelegate {
    
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: STPPaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        
        let clientSecret = "" // Retrieve the PaymentIntent client secret from your backend (see Server-side step above)
        // Call the completion block with the client secret or an error
        completion(clientSecret, "Error");
    }

    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
          switch status {
        case .success:
            // Payment succeeded, show a receipt view
            break
        case .error:
            // Payment failed, show the error
            break
        case .userCancellation:
            // User cancelled the payment
            break
        @unknown default:
            fatalError()
        }
    }
}

extension iBuckBuyViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        dismiss(animated: true, completion: nil)
        Loaf("The Apple Pay transaction was complete.", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

        }
        //The Apple Pay transaction was complete.
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    }
}
