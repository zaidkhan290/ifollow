//
//  StripeCheckoutViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 02/11/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Stripe
import Loaf

class StripeCheckoutViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnPay: UIButton!
    
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        return cardTextField
    }()
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        
        return btnPay
    }()
    
    var totalAmount: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColors()
        btnPay.layer.cornerRadius = btnPay.frame.height / 2
        btnPay.addTarget(self, action: #selector(payWithStripe), for: .touchUpInside)
        bottomView.roundTopCorners(radius: 25)
        bottomView.addShadow(shadowColor: UIColor(red: 5/255, green: 5/255, blue: 5/255, alpha: 0.12).cgColor, shadowOffset: CGSize(width: 0, height: -5), shadowOpacity: 1, shadowRadius: 5)
        let stackView = UIStackView(arrangedSubviews: [titleLbl ,cardTextField, btnPay])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: bottomView.leftAnchor, multiplier: 2),
            bottomView.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: bottomView.topAnchor, multiplier: 2),
        ])
    }
    
    //MARK:- Actions and Method
    
    @IBAction func btnPayTapped(_ sender: UIButton){
        //payWithStripe()
    }
    
    func setColors(){
        self.bottomView.setColor()
        btnPay.setiBuckViewsBackgroundColor()
        btnPay.setiBuckButtonTextColor()
    }
    
    @objc func payWithStripe(){
        let cardParams = STPCardParams()
        cardParams.number = cardTextField.cardNumber
        cardParams.expMonth = cardTextField.expirationMonth
        cardParams.expYear = cardTextField.expirationYear
        cardParams.cvc = cardTextField.cvc

        // Pass it to STPAPIClient to create a Token
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let token = token else {
                Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(2)) { (action) in
                }
                return
            }
            let tokenID = token.tokenId
            var paymentAmount = self.totalAmount * 100
            paymentAmount = paymentAmount.rounded()
            let amount: Int = Int(exactly: paymentAmount)!
            let req: [String: Any] = ["token": tokenID, "description": "ios-payment", "amount": amount]
            self.PaymentRequest(params: req)
            // Send the token identifier to your server...
        }
    }
    
    func PaymentRequest(params: [String: Any]){
        Utility.showOrHideLoader(shouldShow: true)
        API.sharedInstance.executeAPI(type: .stripePayment, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "proceedAfterStripe"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (action) in
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (action) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}
