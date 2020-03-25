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
    
    @objc dynamic var postMedia: String = ""
    @objc dynamic var postDescription: String = ""
    @objc dynamic var postLocation: String = ""
    @objc dynamic var postCreatedAt: String = ""
    @objc dynamic var postMediaType: String = ""
    
    func updateModelWithJSON(json: JSON){
        postMedia = json["media"].stringValue
        postDescription = json["description"].stringValue
        postLocation = json["location"].stringValue
        postCreatedAt = json["created_at"].stringValue
        postMediaType = json["media_type"].stringValue
    }
    
    static func getAllUserPosts() -> [UserPostsModel]{
        let realm = try! Realm()
        return Array(realm.objects(UserPostsModel.self))
    }
}
