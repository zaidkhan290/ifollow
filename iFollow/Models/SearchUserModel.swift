//
//  SearchUserModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 09/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class SearchUserModel: NSObject {
    
    var userId: Int = 0
    var userFullName: String = ""
    var userName: String = ""
    var userImage: String = ""
    var userCountry: String = ""
    
    func updateModelWithJSON(json: JSON){
        userId = json["id"].intValue
        userFullName = json["name"].stringValue
        userName = json["username"].stringValue
        userImage = json["image"].stringValue.replacingOccurrences(of: "\\", with: "")
        userCountry = json["country"].stringValue
    }
    
}
