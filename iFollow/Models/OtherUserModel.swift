//
//  OtherUserModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 25/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class OtherUserModel: NSObject{
    
    var userFirstName: String = ""
    var userLastName: String = ""
    var userFullName: String = ""
    var userBio: String = ""
    var userCountry: String = ""
    var userImage: String = ""
    var userRequestStatus: String = ""
    var userTrendersCount: Int = 0
    var userTrendingsCount: Int = 0
    var userPostsCount: Int = 0
    var userPosts = [OtherUserPostModel]()
    
    func updateModelWithJSON(json: JSON){
        let userData = json["message"].arrayValue.first!
        userFirstName = userData["first_name"].stringValue
        userLastName = userData["last_name"].stringValue
        userFullName = "\(userFirstName) \(userLastName)"
        userBio = userData["short_bio"].stringValue
        userCountry = userData["country"].stringValue
        userRequestStatus = userData["request_status"].stringValue
        userImage = userData["image"].stringValue.replacingOccurrences(of: "\\", with: "")
        userTrendersCount = userData["trenders"].intValue
        userTrendingsCount = userData["trendings"].intValue
        userPostsCount = userData["posts"].intValue
        let userPosts = json["posts"].arrayValue
        for post in userPosts{
            let model = OtherUserPostModel()
            model.updateModelWithJSON(json: post)
            self.userPosts.append(model)
        }
    }
}

class OtherUserPostModel: NSObject{
    
    var postId: Int = 0
    var postMedia: String = ""
    var postDescription: String = ""
    var postLocation: String = ""
    var postCreatedAt: String = ""
    var postMediaType: String = ""
    var postLikes: Int = 0
    var postComments: Int = 0
    var isPostLike: Int = 0
    
    func updateModelWithJSON(json: JSON){
        postId = json["post_id"].intValue
        postMedia = json["media"].stringValue
        postDescription = json["description"].stringValue
        postLocation = json["location"].stringValue
        postCreatedAt = json["created_at"].stringValue
        postMediaType = json["media_type"].stringValue
        postLikes = json["post_likes"].intValue
        postComments = json["post_comments"].intValue
        isPostLike = json["isLiked"].intValue
    }
    
}
