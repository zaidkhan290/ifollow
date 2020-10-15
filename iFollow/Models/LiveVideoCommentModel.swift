//
//  LiveVideoCommentModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/10/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation

class LiveVideoCommentModel: NSObject {
    
    var commentUserId: Int = 0
    var commentUserName: String = ""
    var commentUserImage: String = ""
    var comment: String = ""
    var commentTime: Double = 0.0
    
    init(userId: Int, username: String, userImage: String, comment: String, time: Double){
        self.commentUserId = userId
        self.commentUserName = username
        self.commentUserImage = userImage
        self.comment = comment
        self.commentTime = time
    }
    
}
