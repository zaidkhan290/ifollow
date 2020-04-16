//
//  API.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias completionBlock = (StatusCodes,JSON,String) -> ()

enum EndPoint: String {
    case login = "login"
    case signup = "register"
    case forgotPassword = "forgot_password"
    case changePassword = "change_password"
    case updateProfile = "update_profile"
    case updateProfilePicture = "update_profile_picture"
    case createStory = "add_story"
    case createPost = "add_post"
    case stickers = "stickers"
    case getMyProfile = "profile_page"
    case getOtherUserProfile = "user_page"
    case reportUser = "report_user"
    case blockUser = "block_user"
    case trendRequest = "trend"
    case untrendUser = "un_trend"
    case getNotifications = "notifications"
    case acceptTrendRequest = "accept_trend"
    case rejectTrendRequest = "reject_trend"
    case homePage = "home_page"
    case likePost = "post_like"
    case getPostTrends = "post_likes"
    case updateUserSettings = "user_settings"
    case viewStory = "story_view"
    case hidePost = "post_hide"
    case deletePost = "delete_post"
    case deleteStory = "delete_story"
    case searchUsers = "search_users"
    case createChatRoom = "create_chat_room"
    case getNormalChatsList = "chat_record_list"
    case getPrivateChatsList = "private_chat_record_list"
    case getBlockUsers = "blocked_users_list"
    case unblockUser = "unblock_user"
    case getPostDetail = "post"
    case getStoryViews = "story_views"
    case getTrendersAndTrendings = "getTrendsAndTrenders"
    case createGroup = "create_group_chat_room"
    case getAllGroups = "group_chat_record_list"
    case leaveGroup = "leave_group_chat_room"
    case deactivateGroup = "delete_group_chat_room"
    case updateGroupNotificationSetting = "notification_settings"
    case updateGroup = "update_group_chat_room"
}

enum StatusCodes {
    case success
    case failure
    case authError
}

class API: NSObject {
    
    static let sharedInstance = API()
    
    private override init() {
    }
    
    func executeAPI(type: EndPoint,method: HTTPMethod, params: Parameters? = nil, imageData: Data? = nil, completion: completionBlock?){
        
        URLCache.shared.removeAllCachedResponses()
        var request: DataRequest!
        
        var headers = HTTPHeaders()
        if let user = UserModel.getCurrentUser(){
            headers = ["Content-Type":"application/json",
                       "x-access-token": "\(user.userToken)"]
        }
        else{
            if (type == .signup){
                headers = ["Content-Type":"multipart/form-data"]
            }
            else{
                headers = ["Content-Type":"application/json"]
            }
            
        }
        
        let endPoint = type.rawValue
        
        if (type == .signup || type == .updateProfilePicture){
            Alamofire.upload(multipartFormData: { (multipart) in
                if let data = imageData{
                    multipart.append(data, withName: "image", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
                if params != nil{
                    for (key, value) in params!{
                        multipart.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
                
            }, to: BASEURL + endPoint, method: method, headers: headers) { (result) in

                switch result{
                case .success(let upload, _, _):
                    upload.responseJSON { response in

                        if response.response?.statusCode == 401{
                            completion?(.authError,JSON.null,"UnAuthorized User")
                            return
                        }

                        if let error = response.result.error{
                            var errorDescription = error.localizedDescription
                            if errorDescription == "The Internet connection appears to be offline."{
                                errorDescription = "No Internet Connection"
                            }
                            completion?(.failure,JSON.null,errorDescription)
                            return
                        }

                        if let value = response.result.value {
                            let json = JSON(value)
                            
                            if (response.response?.statusCode == 200){
                                completion?(.success,JSON(value),json["message"].stringValue)
                            }
                            else if (response.response?.statusCode == 503){
                                completion?(.failure,JSON(value),"Server Error")
                            }
                            else{
                                completion?(.failure,JSON(value),json["message"].stringValue)
                            }

                            return
                        }

                        completion?(.failure,JSON.null,"Something went wrong, please try again!")
                    }
                case .failure(let error):
                    completion?(.failure,JSON.null,error.localizedDescription)
                }


            }
        }
        else{
        
            request = Alamofire.request(BASEURL + endPoint, method: method, parameters: params, encoding: method == .get ? URLEncoding.queryString : JSONEncoding.default, headers:headers)
            
            request.responseJSON { response in
                
                if response.response?.statusCode == 401{
                    completion?(.authError,JSON.null,"UnAuthorized User")
                    return
                }
                
                if let error = response.result.error{
                    var errorDescription = error.localizedDescription
                    if errorDescription == "The Internet connection appears to be offline."{
                        errorDescription = "No Internet Connection"
                    }
                    completion?(.failure,JSON.null,errorDescription)
                    return
                }
                
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if (response.response?.statusCode == 200){
                        completion?(.success,JSON(value),json["message"].stringValue)
                    }
                    else if (response.response?.statusCode == 503){
                        completion?(.failure,JSON(value),"Server Error")
                    }
                    else{
                        completion?(.failure,JSON(value),json["message"].stringValue)
                    }
                    
                    return
                }
                
                completion?(.failure,JSON.null,"Something went wrong, please try again!")
            }
        }
        
    }
    
}

