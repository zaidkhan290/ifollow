//
//  GroupChatModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 16/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class GroupChatModel: NSObject {
    
    var groupChatId: String = ""
    var groupAdminId: Int = 0
    var groupAdminName: String = ""
    var groupName: String = ""
    var groupImage: String = ""
    var groupCreatedAt: String = ""
    var groupLastMessageUserId: String = ""
    var groupLastMessage: String = ""
    var groupLastMessageTime: Double = 0.0
    var userClearChatTime: Double = 0.0
    var groupUsers = [GroupMembersModel]()
    
    func updateModelWithJSON(json: JSON){
        groupChatId = json["chat_room_id"].stringValue
        groupAdminId = json["admin_id"].intValue
        groupAdminName = json["admin_name"].stringValue
        groupName = json["group_name"].stringValue
        groupImage = json["image"].stringValue
        userClearChatTime = json["chat_clear_time"].doubleValue
        groupCreatedAt = json["created_at"].stringValue
        let groupCreatedDate = Utility.getNotificationDateFrom(dateString: json["created_at"].stringValue)
        let groupDateTimeStamp = groupCreatedDate.timeIntervalSince1970
        let groupCreatedTimeInMillisecods = groupDateTimeStamp * 1000
        groupLastMessageTime = groupCreatedTimeInMillisecods
        
        let groupMembers = json["user_list"].arrayValue
        for member in groupMembers{
            let model = GroupMembersModel()
            model.updateModelWithJSON(json: member)
            groupUsers.append(model)
        }
        
    }
    
}

class GroupMembersModel: NSObject{
    
    var userId: Int = 0
    var userFullName: String = ""
    var userImage: String = ""
    var userAllowNotification: Int = 1
    
    func updateModelWithJSON(json: JSON){
        userId = json["user_id"].intValue
        userFullName = json["user_name"].stringValue
        userImage = json["image"].stringValue.replacingOccurrences(of: "\\", with: "")
        if (json["notification_status"] == JSON.null){
            userAllowNotification = 1
        }
        else{
            userAllowNotification = json["notification_status"].intValue
        }
        
    }
    
}
