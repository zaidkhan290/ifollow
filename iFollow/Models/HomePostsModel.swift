//
//  HomePostsModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class HomePostsModel: Object{
    
    @objc dynamic var postUserId: Int = 0
    @objc dynamic var postUserFullName: String = ""
    @objc dynamic var postUserName: String = ""
    @objc dynamic var postUserCountry: String = ""
    @objc dynamic var postUserImage: String = ""
    @objc dynamic var postId: Int = 0
    @objc dynamic var postLikes: Int = 0
    @objc dynamic var postComments: Int = 0
    @objc dynamic var isPostLike: Int = 0
    @objc dynamic var postMedia: String = ""
    @objc dynamic var postLocation: String = ""
    @objc dynamic var postDescription: String = ""
    @objc dynamic var postMediaType: String = ""
    @objc dynamic var postTime: String = ""
    @objc dynamic var shouldShowPostTrends: Int = 0
    
    func updateModelWithJSON(json: JSON){
        postUserId = json["user_id"].intValue
        postUserFullName = json["name"].stringValue
        postUserName = json["username"].stringValue
        postUserCountry = json["country"].stringValue
        postUserImage = json["user_image"].stringValue.replacingOccurrences(of: "\\", with: "")
        postId = json["post_id"].intValue
        postLikes = json["post_likes"].intValue
        postComments = json["post_comments"].intValue
        isPostLike = json["isLiked"].intValue
        postMedia = json["media"].stringValue
        postLocation = json["location"].stringValue
        postDescription = json["description"].stringValue
        postMediaType = json["media_type"].stringValue
        postTime = json["created_at"].stringValue
        shouldShowPostTrends = json["post_view_settings"].intValue
    }
    
    static func getAllHomePosts() -> [HomePostsModel]{
        let realm = try! Realm()
        return Array(realm.objects(HomePostsModel.self))
    }
    
}
