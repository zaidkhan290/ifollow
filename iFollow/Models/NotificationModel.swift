//
//  NotificationModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 25/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class NotificationModel: Object{
    
    @objc dynamic var notificationId: Int = 0
    @objc dynamic var notificationUserId: String = ""
    @objc dynamic var notificationFriendId: Int = 0
    @objc dynamic var notificationFriendImage: String = ""
    @objc dynamic var notificationFriendName: String = ""
    @objc dynamic var notificationMessage: String = ""
    @objc dynamic var notificationTag: String = ""
    @objc dynamic var notificationRequestId: String = ""
    @objc dynamic var notificationDate: String = ""
    
    func updateModelWithJSON(json: JSON){
        notificationId = json["id"].intValue
        notificationUserId = json["user_id"].stringValue
        notificationFriendId = json["friend_id"].intValue
        notificationFriendImage = json["image"].stringValue.replacingOccurrences(of: "\\", with: "")
        notificationFriendName = json["name"].stringValue
        notificationMessage = json["message"].stringValue
        notificationTag = json["tag"].stringValue
        notificationRequestId = json["request_id"].stringValue
        notificationDate = json["date"].stringValue
    }
    
    static func getAllNotifications() -> [NotificationModel]{
        let realm = try! Realm()
        return Array(realm.objects(NotificationModel.self))
    }
    
}

