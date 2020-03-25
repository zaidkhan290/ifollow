//
//  Utility.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import RealmSwift
import AVFoundation

struct Utility {
    
    static let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
    static private var timeFormatter: DateFormatter?
    
    static func getLoginNavigationController() -> UINavigationController{
        return storyBoard.instantiateViewController(withIdentifier: "LoginNavigation") as! UINavigationController
    }
    
    static func getMainViewController() -> MainViewController{
        return storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
    }
    
    static func getLoginViewController() -> LoginViewController{
        return storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    static func getSignupViewController() -> SignupViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
    }
    
    static func getForgotPasswordViewController() -> ForgotPasswordViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
    }
    
    static func getSetPasswordViewController() -> SetPasswordViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SetPasswordViewController") as! SetPasswordViewController
    }
    
    static func getHomeViewController() -> HomeViewController{
        return storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    }
    
    static func getExploreViewController() -> ExploreViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ExploreViewController") as! ExploreViewController
    }
    
    static func getNotificationViewController() -> NotificationViewController{
        return storyBoard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
    }
    
    static func getTabBarViewController() -> TabBarViewController{
        return storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
    }
    
    static func getCameraViewController() -> CameraViewController{
        return storyBoard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
    }
    
    static func getProfileViewController() -> ProfileViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
    }
    
    static func getChatBoxContainerViewController() -> ChatBoxContainerViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ChatBoxContainerViewController") as! ChatBoxContainerViewController
    }
    
    static func getAllChatsListViewController() -> AllChatsListViewController{
        return storyBoard.instantiateViewController(withIdentifier: "AllChatsListViewController") as! AllChatsListViewController
    }
    
    static func getAllGroupsListViewController() -> AllGroupsListViewController{
        return storyBoard.instantiateViewController(withIdentifier: "AllGroupsListViewController") as! AllGroupsListViewController
    }
    
    static func getEditProfileViewController() -> EditProfileViewController{
        return storyBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
    }
    
    static func getMenuViewController() -> MenuViewController{
        return storyBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    }
    
    static func getPrivacyViewController() -> PrivacyViewController{
        return storyBoard.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
    }
    
    static func getPrivateChatBoxViewControllers() -> PrivateChatBoxViewController{
        return storyBoard.instantiateViewController(withIdentifier: "PrivateChatBoxViewController") as! PrivateChatBoxViewController
    }
    
    static func getOtherUserProfileViewController() -> OtherUserProfileViewController{
        return storyBoard.instantiateViewController(withIdentifier: "OtherUserProfileViewController") as! OtherUserProfileViewController
    }
    
    static func getCreateGroupViewController() -> CreateGroupViewController{
        return storyBoard.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
    }
    
    static func getSignupDetail1ViewController() -> SignupDetail1ViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SignupDetail1ViewController") as! SignupDetail1ViewController
    }
    
    static func getSignupDetail2ViewController() -> SignupDetail2ViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SignupDetail2ViewController") as! SignupDetail2ViewController
    }
    
    static func getOptionsViewController() -> OptionsViewController{
        return storyBoard.instantiateViewController(withIdentifier: "OptionsViewController") as! OptionsViewController
    }
    
    static func getStoriesViewController() -> StoriesViewController{
        return storyBoard.instantiateViewController(withIdentifier: "StoriesViewController") as! StoriesViewController
    }
    
    static func getSendStoryViewController() -> SendStoryViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SendStoryViewController") as! SendStoryViewController
    }
    
    static func getViewersViewController() -> ViewersViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ViewersViewController") as! ViewersViewController
    }
    
    static func getNewPostViewController() -> NewPostViewController{
        return storyBoard.instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
    }
    
    static func getTrendersContainerViewController() -> TrendersContainerViewController{
        return storyBoard.instantiateViewController(withIdentifier: "TrendersContainerViewController") as! TrendersContainerViewController
    }
    
    static func getTrendesViewController() -> TrendesViewController{
        return storyBoard.instantiateViewController(withIdentifier: "TrendesViewController") as! TrendesViewController
    }
    
    static func getTrendingViewController() -> TrendingViewController{
        return storyBoard.instantiateViewController(withIdentifier: "TrendingViewController") as! TrendingViewController
    }
    
    static func getChatContainerViewController() -> ChatContainerViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
    }
    
    static func getChatViewController() -> ChatViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
    }
    
    static func getGroupDetailViewController() -> GroupDetailViewController{
        return storyBoard.instantiateViewController(withIdentifier: "GroupDetailViewController") as! GroupDetailViewController
    }
    
    static func getMediaViewController() -> MediaViewController{
        return storyBoard.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
    }
    
    static func getAddMembersViewController() -> AddMembersViewController{
        return storyBoard.instantiateViewController(withIdentifier: "AddMembersViewController") as! AddMembersViewController
    }
    
    static func getCommentViewController() -> CommentViewController{
        return storyBoard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
    }
    
    static func getEmojisViewController() -> EmojisViewController{
        return storyBoard.instantiateViewController(withIdentifier: "EmojisViewController") as! EmojisViewController
    }
    
    static func getLoginUserId() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userId
        }
        return 0
    }
    
    static func getLoginUserTrendersCount() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userTrenders
        }
        return 0
    }
    
    static func getLoginUserTrendingsCount() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userTrendings
        }
        return 0
    }
    
    static func getLoginUserPostsCount() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userPosts
        }
        return 0
    }
    
    static func getLoginUserFirstName() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userFirstName
        }
        return ""
    }
    
    static func getLoginUserLastName() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userLastName
        }
        return ""
    }
    
    static func getLoginUserFullName() -> String{
        if let user = UserModel.getCurrentUser(){
            return "\(user.userFirstName) \(user.userLastName)"
        }
        return ""
    }
    
    static func getLoginUserCountry() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userCountry
        }
        return ""
    }
    
    static func getLoginUserImage() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userImage
        }
        return ""
    }
    
    static func getLoginUserBio() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userShortBio
        }
        return ""
    }
    
    static var storyTimeFormatter: DateFormatter{
        get{
            if (timeFormatter == nil){
                timeFormatter = DateFormatter()
                timeFormatter?.timeZone = .current
                timeFormatter?.timeStyle = .medium
                timeFormatter?.dateFormat = "hh:mm a" //2019-12-12 16:50:31
            }
            return timeFormatter!
        }
        set{
            
        }
    }
    
    static func getCurrentTime() -> String{
        let date = Date()
        let time = storyTimeFormatter.string(from: date)
        return time
    }
    
    static func setTextFieldPlaceholder(textField: UITextField, placeholder: String, color: UIColor){
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: color])

    }
    
    static func isValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    static func isValid(password: String) -> Bool {
        return (password.count < 6 || password.count > 16) ? false : true
    }
    
    static func showOrHideLoader(shouldShow: Bool){
        let activityData = ActivityData(size: CGSize(width: 60, height: 60), message: "", messageFont: nil, messageSpacing: nil, type: .ballRotateChase, color: Theme.profileLabelsYellowColor, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: 2, backgroundColor: .clear, textColor: nil)
        if (shouldShow){
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        }
        else{
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    static func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVURLAsset(url: url)
        
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print("Error: \(error)")
            return nil
        }
        
        return UIImage(cgImage: thumbnailImageRef)
    }
    
    static func logoutUser(){
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.deleteAll()
        }
        let vc = Utility.getLoginNavigationController()
        UIWINDOW!.rootViewController = vc
    }
}
