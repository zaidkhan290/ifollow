//
//  UserModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 17/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class UserModel: Object {
    
    @objc dynamic var userId: Int = 0
    @objc dynamic var userFirstName: String = ""
    @objc dynamic var userLastName: String = ""
    @objc dynamic var userDOB: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var userShortBio: String = ""
    @objc dynamic var userHobby: String = ""
    @objc dynamic var userCountry: String = ""
    @objc dynamic var userImage: String = ""
    @objc dynamic var userZipCode: String = ""
    @objc dynamic var userGender: String = ""
    @objc dynamic var userEmail: String = ""
    @objc dynamic var userPassword: String = ""
    @objc dynamic var userRegisteredAt: String = ""
    @objc dynamic var userUpdatedAt: String = ""
    @objc dynamic var userCode: String = ""
    @objc dynamic var userToken: String = ""
    
    func updateModelWithJSON(json: JSON){
        userId = json["id"].intValue
        userFirstName = json["first_name"].stringValue
        userLastName = json["last_name"].stringValue
        userDOB = json["date_of_birth"].stringValue
        username = json["username"].stringValue
        userShortBio = json["short_bio"].stringValue
        userHobby = json["hobby"].stringValue
        userCountry = json["country"].stringValue
        userImage = json["image"].stringValue.replacingOccurrences(of: "\\", with: "")
        userZipCode = json["zip_code"].stringValue
        userGender = json["gender"].stringValue
        userEmail = json["email"].stringValue
        userPassword = json["password"].stringValue
        userRegisteredAt = json["registered_at"].stringValue
        userUpdatedAt = json["updated_at"].stringValue
        userCode = json["code"].stringValue
        userToken = json["jwt"].stringValue
    }
    
    static func getCurrentUser() -> UserModel?{
        let realm = try! Realm()
        if let model = realm.objects(UserModel.self).first{
            return model
        }
        return nil
    }
    
}
