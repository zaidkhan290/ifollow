//
//  StoryUserModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class StoryUserModel: Object {
    
    @objc dynamic var userId: Int = 0
    @objc dynamic var userName: String = ""
    @objc dynamic var userImage: String = ""
    @objc dynamic var isAllStoriesViewed: Bool = false
    @objc dynamic var lastStoryMediaType: String = ""
    @objc dynamic var lastStoryPreview: String = ""
    dynamic var userStories = List<UserStoryModel>()
    
    func updateModelWithJSON(json: JSON, isForMyStory: Bool){
        
        if (isForMyStory){
            userId = Utility.getLoginUserId()
            userName = Utility.getLoginUserFullName()
            userImage = Utility.getLoginUserImage()
            let stories = json["my_stories"].arrayValue
            for story in stories{
                let model = UserStoryModel()
                model.updateModelWithJSON(json: story)
                userStories.append(model)
            }
        }
        else{
            userId = json["user_id"].intValue
            userName = json["user_name"].stringValue
            userImage = json["user_image"].stringValue.replacingOccurrences(of: "\\", with: "")
            let stories = json["stories"].arrayValue
            for story in stories{
                let model = UserStoryModel()
                model.updateModelWithJSON(json: story)
                userStories.append(model)
            }
        }
        
    }
    
    static func getMyStory() -> [StoryUserModel]{
        let realm = try! Realm()
        return Array(realm.objects(StoryUserModel.self).filter("userId = \(Utility.getLoginUserId())"))
    }
    
    static func getFollowersUsersStories() -> [StoryUserModel]{
        let realm = try! Realm()
        return Array(realm.objects(StoryUserModel.self).filter("userId != \(Utility.getLoginUserId())"))
    }
    
}

class UserStoryModel: Object {
    
    @objc dynamic var storyId: Int = 0
    @objc dynamic var storyMediaType: String = ""
    @objc dynamic var storyURL: String = ""
    @objc dynamic var isStoryViewed: Int = 0
    @objc dynamic var storyTime: String = ""
    @objc dynamic var shouldShowStoryViews: Int = 0
    
    func updateModelWithJSON(json: JSON){
        storyId = json["story_id"].intValue
        storyMediaType = json["media_type"].stringValue
        storyURL = json["media"].stringValue
        isStoryViewed = json["isViewed"].intValue
        storyTime = json["created_at"].stringValue
        shouldShowStoryViews = json["story_view_settings"].intValue
    }
    
}
