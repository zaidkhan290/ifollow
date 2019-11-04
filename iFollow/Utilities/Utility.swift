//
//  Utility.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

struct Utility {
    
    static let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
    
    static func getMainViewController() -> MainViewController{
        return storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
    }
    
    static func getLoginViewController() -> LoginViewController{
        return storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    static func getSignupViewController() -> SignupViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
    }
    
    static func getForgotPasswordViewController() -> ForgotPasswordViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
    }
    
    static func setTextFieldPlaceholder(textField: UITextField, placeholder: String, color: UIColor){
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: color])

    }
    
}
