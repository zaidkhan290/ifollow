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
    var userVerifiedStatus: Int = 0
    var userFullName: String = ""
    var userBio: String = ""
    var userEmail: String = ""
    var userCountry: String = ""
    var userImage: String = ""
    var userRequestStatus: String = ""
    var userProfileStatus: String = ""
    var userTrendStatus: String = ""
    var userTrendersCount: Int = 0
    var userTrendingsCount: Int = 0
    var userPostsCount: Int = 0
    var userPosts = [OtherUserPostModel]()
    
    func updateModelWithJSON(json: JSON){
        let userData = json["message"].arrayValue.first!
        userFirstName = userData["first_name"].stringValue
        userLastName = userData["last_name"].stringValue
        userVerifiedStatus = userData["verified"].intValue
        userFullName = "\(userFirstName) \(userLastName)"
        userBio = userData["short_bio"].stringValue
        userEmail = userData["email"].stringValue
        userCountry = userData["country"].stringValue
        userRequestStatus = userData["request_status"].stringValue
        userProfileStatus = userData["profile_status"].stringValue
        userTrendStatus = userData["trend_status"].stringValue
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
    var shouldShowPostTrends: Int = 0
    var postBoostLink: String = ""
    var postStatus: String = ""
    var postTags: String = ""
    var postOriginalUserId: Int = 0
    var postOriginalUserFullName: String = ""
    var isPublicComment: Int = 0

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
        shouldShowPostTrends = json["post_view_settings"].intValue
        postBoostLink = json["post_boost_link"].stringValue
        postStatus = json["status"].stringValue
        postTags = json["tags"].stringValue
        postOriginalUserId = json["original_id"].intValue
        postOriginalUserFullName = json["original_name"].stringValue
        isPublicComment = json["public_comments"].intValue
    }
    
}
