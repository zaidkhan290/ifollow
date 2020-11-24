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
    @objc dynamic var userPostExpireHours: Int = 0
    @objc dynamic var userStoryExpireHours: Int = 0
    @objc dynamic var userProfileStatus: String = ""
    @objc dynamic var userTrendStatus: String = "public"
    @objc dynamic var isUserPostViewEnable: Int = 0
    @objc dynamic var isUserStoryViewEnable: Int = 0
    @objc dynamic var isAppointmentAllow: Int = 1
    @objc dynamic var userSettingVersion: Int = 0
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
    @objc dynamic var userTrenders: Int = 0
    @objc dynamic var userTrendings: Int = 0
    @objc dynamic var userPosts: Int = 0
    @objc dynamic var userBuck: Int = 0
    @objc dynamic var userToken: String = ""
    
    func updateModelWithJSON(json: JSON){
        
        let user = json["user"]
        let userSettings = json["user_settings"]
        
        userId = user["id"].intValue
        userPostExpireHours = userSettings["post_hours"].intValue
        userStoryExpireHours = userSettings["story_hours"].intValue
        userProfileStatus = userSettings["profile_status"].stringValue
        userTrendStatus = userSettings["trend_status"].stringValue
        isUserPostViewEnable = userSettings["post_view"].intValue
        isUserStoryViewEnable = userSettings["story_view"].intValue
        isAppointmentAllow = userSettings["allow_appointment"].intValue
        userSettingVersion = userSettings["version"].intValue
        userFirstName = user["first_name"].stringValue
        userLastName = user["last_name"].stringValue
        userDOB = user["date_of_birth"].stringValue
        username = user["username"].stringValue
        userShortBio = user["short_bio"].stringValue
        userHobby = user["hobby"].stringValue
        userCountry = user["country"].stringValue
        userImage = user["image"].stringValue.replacingOccurrences(of: "\\", with: "")
        userZipCode = user["zip_code"].stringValue
        userGender = user["gender"].stringValue
        userEmail = user["email"].stringValue
        userPassword = user["password"].stringValue
        userRegisteredAt = user["registered_at"].stringValue
        userUpdatedAt = user["updated_at"].stringValue
        userCode = user["code"].stringValue
        userToken = user["jwt"].stringValue
    }
    
    static func getCurrentUser() -> UserModel?{
        let realm = try! Realm()
        if let model = realm.objects(UserModel.self).first{
            return model
        }
        return nil
    }
    
}
