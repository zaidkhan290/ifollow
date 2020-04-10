//
//  ChatListModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 09/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class RecentChatsModel: NSObject{
    
    var chatId: String = ""
    var chatUserId: Int = 0
    var chatUserName: String = ""
    var chatUserImage: String = ""
    var lastMessage: String = ""
    var lastMessageTime: Double = 0.0
    var isRead: Bool = false
    
    func updateModelWithJSON(json: JSON){
        chatId = json["chat_room_id"].stringValue
        chatUserId = json["user_id"].intValue
        chatUserName = json["user_name"].stringValue
        chatUserImage = json["image"].stringValue.replacingOccurrences(of: "\\", with: "")
    }
    
}
