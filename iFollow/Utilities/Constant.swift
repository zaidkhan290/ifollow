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

//Others
let BASEURL = "https://ifollowinc.herokuapp.com/users/"
let UIWINDOW = UIApplication.shared.delegate!.window!
let GOOGLECLIENTID = "977065173099-0sl42r8u3v6hh91nkfhbl2qkb4v3mtgh.apps.googleusercontent.com"
let rootRef = Database.database().reference()
let FireBaseStorageURL = "gs://ifollow-13644.appspot.com"
