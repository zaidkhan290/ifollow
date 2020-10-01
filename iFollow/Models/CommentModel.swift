//
//  CommentModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 01/10/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class CommentModel: NSObject {
    
    var commentId: Int = 0
    var replyCommentId: Int = 0
    var userId: Int = 0
    var userName: String = ""
    var userImage: String = ""
    var comment: String = ""
    var commentDate: String = ""
    var commentReplies = [CommentModel]()
    
    func updateModelWithJSON(json: JSON){
        commentId = json["id"].intValue
        replyCommentId = json["comment_id"].intValue
        userId = json["user_id"].intValue
        userName = json["user_name"].stringValue
        userImage = json["user_image"].stringValue
        comment = json["comment"].stringValue
        commentDate = json["date"].stringValue
        
        let commentRepliesArray = json["replies"].arrayValue
        for reply in commentRepliesArray{
            let model = CommentModel()
            model.updateModelWithJSON(json: reply)
            commentReplies.append(model)
        }
    }
    
//    "comment" : "Yes Murtaza its good",
//    "user_id" : 14,
//    "id" : 2,
//    "comment_id" : 3,
//    "date" : "2020-10-01 11:18:15"
    
}
