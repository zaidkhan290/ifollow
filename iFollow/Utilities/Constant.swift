//
//  Constant.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 17/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//Errors Messages

let kEmailError = "Please enter your valid email address"
let kPasswordError = "Please enter atleast 6 characters password"
let kPasswordNotMatchError = "Password not match"
let kFirstNameError = "Please enter your first name"
let kLastNameError = "Please enter your last name"
let kUsernameError = "Please enter your username"
let kOldPasswordError = "Please enter your old password"
let kTermsAndConditionError = "In order to continue, you need to accept to our Terms & Conditions and Privacy Policy. Kindly tap on provided check box in order to do that"

//Others
let BASEURL = "http://apis.ifollowinc.com:5000/users/"
//let BASEURL = "https://ifollowinc.herokuapp.com/users/"
let UIWINDOW = UIApplication.shared.delegate!.window!
let GOOGLECLIENTID = "977065173099-0sl42r8u3v6hh91nkfhbl2qkb4v3mtgh.apps.googleusercontent.com"
let rootRef = Database.database().reference()
let FireBaseStorageURL = "gs://ifollow-13644.appspot.com"
let GoogleAPIKey = "AIzaSyA7oFL_W-gT4OG1kg-O-q_5S5-LpOPkDSQ"
let adUnitID = "ca-app-pub-3940256099942544/3986624511"
