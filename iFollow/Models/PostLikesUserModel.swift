//
//  PostLikesUserModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class PostLikesUserModel: NSObject{
    
    var userId: Int = 0
    var userFullName: String = ""
    var username: String = ""
    var userCountry: String = ""
    var userImage: String = ""
    var userRequestStatus = ""
    
    func updateModelWithJSON(json: JSON){
        userId = json["user_id"].intValue
        userFullName = json["name"].stringValue
        username = json["username"].stringValue
        userCountry = json["country"].stringValue
        userImage = json["user_image"].stringValue.replacingOccurrences(of: "\\", with: "")
        userRequestStatus = json["request_status"].stringValue
    }
    
}
