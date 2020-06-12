//
//  UserPostsModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 25/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class UserPostsModel: Object{
    
    @objc dynamic var postId: Int = 0
    @objc dynamic var postMedia: String = ""
    @objc dynamic var postDescription: String = ""
    @objc dynamic var postLocation: String = ""
    @objc dynamic var postCreatedAt: String = ""
    @objc dynamic var postMediaType: String = ""
    @objc dynamic var postLikes: Int = 0
    @objc dynamic var postComments: Int = 0
    @objc dynamic var isPostLike: Int = 0
    @objc dynamic var postBoostLink: String = ""
    @objc dynamic var postStatus: String = ""
    
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
        postBoostLink = json["post_boost_link"].stringValue
        postStatus = json["status"].stringValue
    }
    
    static func getAllUserPosts() -> [UserPostsModel]{
        let realm = try! Realm()
        return Array(realm.objects(UserPostsModel.self))
    }
}
