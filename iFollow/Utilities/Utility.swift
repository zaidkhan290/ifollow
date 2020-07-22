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
import DateToolsSwift
import AVKit

struct Utility {
    
    static let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
    static private var timeFormatter: DateFormatter?
    static private var notificationDateFormatter: DateFormatter?
    
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
    
    static func getPostDetailViewController() -> PostDetailViewController{
        return storyBoard.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
    }
    
    static func getExploreViewController() -> ExploreViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ExploreViewController") as! ExploreViewController
    }
    
    static func getSearchViewController() -> SearchViewController{
        return storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
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
    
    static func getShareStoriesViewController() -> ShareStoriesViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ShareStoriesViewController") as! ShareStoriesViewController
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
    
    static func getTimeSettingViewController() -> TimeSettingViewController{
        return storyBoard.instantiateViewController(withIdentifier: "TimeSettingViewController") as! TimeSettingViewController
    }
    
    static func getBlockUsersViewController() -> BlockUsersViewController{
        return storyBoard.instantiateViewController(withIdentifier: "BlockUsersViewController") as! BlockUsersViewController
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
    
    static func getGroupChatViewController() -> GroupChatViewController{
        return storyBoard.instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
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
    
    static func getPrivacyPolicyViewController() -> PrivacyPolicyViewController{
        return storyBoard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
    }
    
    static func getShareViewController() -> ShareViewController{
        return storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
    }
    
    static func getLiveVideoViewController() -> LiveVideoViewController{
        return storyBoard.instantiateViewController(withIdentifier: "LiveVideoViewController") as! LiveVideoViewController
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
    
    static func getLoginUserPostExpireHours() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userPostExpireHours
        }
        return 0
    }
    
    static func getLoginUserStoryExpireHours() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userStoryExpireHours
        }
        return 0
    }
    
    static func getLoginUserIsPostViewEnable() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.isUserPostViewEnable
        }
        return 0
    }
    
    static func getLoginUserIsStoryViewEnable() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.isUserStoryViewEnable
        }
        return 0
    }
    
    static func getLoginUserProfileType() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userProfileStatus
        }
        return ""
    }
    
    static func getLoginUserDisplayTrendStatus() -> String{
        if let user = UserModel.getCurrentUser(){
            return user.userTrendStatus
        }
        return ""
    }
    
    static func getLoginUserSettingVersion() -> Int{
        if let user = UserModel.getCurrentUser(){
            return user.userSettingVersion
        }
        return 0
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
    
    static var serverNotificationDateFormatter: DateFormatter{
        get{
            if (notificationDateFormatter == nil){
                notificationDateFormatter = DateFormatter()
                notificationDateFormatter?.timeZone = TimeZone(abbreviation: "UTC")
                notificationDateFormatter?.dateFormat = "yyyy-MM-dd HH:mm:ss" //2019-12-12 16:50:31
            }
            return notificationDateFormatter!
        }
        set{
            
        }
    }
    
    static func getNotificationDateFrom(dateString: String) -> Date{
        var formattedDate = Date()
        if let notificationDate = serverNotificationDateFormatter.date(from: dateString){
            formattedDate = notificationDate
        }
        return formattedDate
    }
    
    static func getNotificationTime(date: Date) -> String{
        return date.timeAgoSinceNow
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
    
    static func imageFromVideo(url: URL, at time: TimeInterval, totalTime: Double) -> UIImage? {
        let asset = AVURLAsset(url: url)
        
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(totalTime))
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
        var usersRef = rootRef.child("Users")
        usersRef = usersRef.child("\(Utility.getLoginUserId())")
        usersRef.updateChildValues(["isActive" : false])
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.deleteAll()
        }
        let vc = Utility.getLoginNavigationController()
        UIWINDOW!.rootViewController = vc
    }
    
    static func encodeVideo(videoUrl: URL, outputUrl: URL? = nil, resultClosure: @escaping (URL?) -> Void ) {
        
        var finalOutputUrl: URL? = outputUrl
        
        if finalOutputUrl == nil {
            var url = videoUrl
            url.deletePathExtension()
            url.appendPathExtension("\(UUID().uuidString).mp4")
            finalOutputUrl = url
        }
        
        if FileManager.default.fileExists(atPath: finalOutputUrl!.path) {
            print("Converted file already exists \(finalOutputUrl!.path)")
            resultClosure(finalOutputUrl)
            return
        }
        
        let asset = AVURLAsset(url: videoUrl)
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) {
            exportSession.outputURL = finalOutputUrl!
            exportSession.outputFileType = AVFileType.mp4
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: asset.duration)
            exportSession.timeRange = range
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously() {
                
                switch exportSession.status {
                case .failed:
                    print("Export failed: \(exportSession.error != nil ? exportSession.error!.localizedDescription : "No Error Info")")
                case .cancelled:
                    print("Export canceled")
                case .completed:
                    resultClosure(finalOutputUrl!)
                default:
                    break
                }
            }
        } else {
            resultClosure(nil)
        }
    }
    
    static public func timeAgoSince(_ date: Date) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        }
        
        if let year = components.year, year >= 1 {
            return "Last year"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month) months ago"
        }
        
        if let month = components.month, month >= 1 {
            return "Last month"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "Last week"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }
        
        if let day = components.day, day >= 1 {
            return "Yesterday"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "A minute ago"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        }
        
        return "Just now"
        
    }
    
    static func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
}
