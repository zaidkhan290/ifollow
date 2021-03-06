//
//  HomeViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel
import FirebaseStorage
import Loaf
import CoreLocation
import Lightbox
import AVKit
import AVFoundation
import RealmSwift
import Firebase
import GoogleMobileAds
import AgoraRtcKit

class HomeViewController: UIViewController {

    @IBOutlet weak var storyCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    @IBOutlet weak var emptyStateView: UIView!
    
    var isFullScreen = false
    var storyImage = UIImage()
    var storageRef: StorageReference?
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    var userCurrentAddress = ""
    var userLatitude = 0.0
    var userLongitude = 0.0
    var postsArray = [HomePostsModel]()
    var optionsPopupIndex = 0
    
    var myStoryArray = [StoryUserModel]()
    var followersStoriesArray = [StoryUserModel]()
    
    var adLoader: GADAdLoader!
    var heightConstraint : NSLayoutConstraint?
    var nativeAdView: GADUnifiedNativeAdView!
    
    var isFromPush = false
    var pushTitle = ""
    var pushDesc = ""
    var tagUserIds = [Int]()
    
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: kAgoraAppID, delegate: nil)
        engine.setLogFilter(AgoraLogFilter.info.rawValue)
        engine.setLogFile(FileCenter.logFilePath())
        return engine
    }()
    
    private var settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHomeScreenColor()
        let storyCell = UINib(nibName: "StoryCollectionViewCell", bundle: nil)
        self.storyCollectionView.register(storyCell, forCellWithReuseIdentifier: "StoryCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 105, height: self.storyCollectionView.frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.storyCollectionView.collectionViewLayout = layout
        self.storyCollectionView.showsHorizontalScrollIndicator = false
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.getHomeData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshHomeData), name: NSNotification.Name(rawValue: "refreshHomeData"), object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(refreshHomeData), name: NSNotification.Name(rawValue: "refreshHomeDataAfterViewedStory"), object: nil)
        updateDeviceToken()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
        usersRef.updateChildValues(["isActive" : true])
        getHomeData()
    }
    
    //MARK:- Methods
    
    func setHomeScreenColor(){
        if (traitCollection.userInterfaceStyle == .dark){
            self.view.backgroundColor = Theme.darkModeBlackColor
        }
        else{
            self.view.backgroundColor = .white
        }
        self.carouselView.reloadData()
    }
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        vc.delegate = self
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.isNavigationBarHidden = true
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func refreshHomeData(){
        if (postsArray.count > 0){
            self.carouselView.scrollToItem(at: 0, animated: true)
        }
        getHomeData()
    }
    
    @objc func showOptionsPopup(sender: UIButton){
        
        optionsPopupIndex = sender.tag
        let vc = Utility.getOptionsViewController()
        vc.options = ["Hide", "Share"]
        vc.delegate = self
        vc.isFromPostView = true
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 100, height: 100)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = sender
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func showHidePostPopup(){
        let alertVC = UIAlertController(title: "Hide Post", message: "Are you sure you want to hide this post?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["post_id": self.postsArray[self.optionsPopupIndex].postId]
                self.postsArray.remove(at: self.optionsPopupIndex)
                self.carouselView.removeItem(at: self.optionsPopupIndex, animated: true)
                Loaf("Post Hide", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                    
                }
                API.sharedInstance.executeAPI(type: .hidePost, method: .post, params: params, completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        if (status == .authError){
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                Utility.logoutUser()
                            }
                        }
                    }
                })
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func saveStoryImageToFirebase(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel]){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/StoryImage\(timeStemp).jgp")
        
        //        let imageData2 = UIImagePNGRepresentation(image)
        if let imageData2 = image.jpegData(compressionQuality: 1) {
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
        //    Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = picRef?.putData(imageData2, metadata: metadata, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    picRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
                            
                            if (isToSendMyStory){
                                self.postStory(mediaUrl: imageURL.absoluteString, postType: "image", caption: caption)
                            }
                            for friend in friendsArray{
                                
                                if (friend.chatId == ""){
                                    let params = ["user_id": friend.chatUserId,
                                                  "is_private": 0]
                                    
                                    API.sharedInstance.executeAPI(type: .createChatRoom, method: .post, params: params) { (status, result, message) in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if (status == .success){
                                                let chatId = result["chat_room_id"].stringValue
                                                if (chatId != ""){
                                                    let chatRef = rootRef.child("NormalChats").child(chatId)
                                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                                               "message": imageURL.absoluteString,
                                                                                               "type": 2,
                                                                                               "isRead": false,
                                                                                               "timestamp" : ServerValue.timestamp()])
                                                    
                                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                                               "message": "\(Utility.getLoginUserFullName()) shared a story with you",
                                                                                               "type": 1,
                                                                                               "isRead": false,
                                                                                               "timestamp" : ServerValue.timestamp()])
                                                    
                                                    Utility.showOrHideLoader(shouldShow: false)
                                                }
                                                else{
                                                    Loaf("Failed to create chat room", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                                    }
                                                }
                                                
                                            }
                                            else if (status == .failure){
                                                Utility.showOrHideLoader(shouldShow: false)
                                                Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                                }
                                            }
                                            else if (status == .authError){
                                                Utility.showOrHideLoader(shouldShow: false)
                                                Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                                    Utility.logoutUser()
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                else{
                                    let chatRef = rootRef.child("NormalChats").child(friend.chatId)
                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                               "message": imageURL.absoluteString,
                                                                               "type": 2,
                                                                               "isRead": false,
                                                                               "timestamp" : ServerValue.timestamp()])
                                    
                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                               "message": "\(Utility.getLoginUserFullName()) shared a story with you",
                                                                               "type": 1,
                                                                               "isRead": false,
                                                                               "timestamp" : ServerValue.timestamp()])
                                    
                                    Utility.showOrHideLoader(shouldShow: false)
                                }
                                
                                
                            }
                            if (friendsArray.count > 0){
                                Loaf("Story Sent", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                    
                                }
                            }
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
              //  Utility.showOrHideLoader(shouldShow: true)
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func saveStoryVideoToFirebase(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel]){
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Videos")
        let videoRef = iosRef?.child("/StoryVideo\(timeStemp).mov")
        
        if let videoData = try? Data(contentsOf: videoURL){
            
        //    Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = videoRef?.putData(videoData, metadata: nil, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    videoRef?.downloadURL(completion: { (url, error) in
                        if let videoURL = url{
                            
                            if (isToSendMyStory){
                                self.postStory(mediaUrl: videoURL.absoluteString, postType: "video", caption: caption)
                            }
                            for friend in friendsArray{
                                
                                if (friend.chatId == ""){
                                    let params = ["user_id": friend.chatUserId,
                                                  "is_private": 0]
                                    
                                    API.sharedInstance.executeAPI(type: .createChatRoom, method: .post, params: params) { (status, result, message) in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if (status == .success){
                                                let chatId = result["chat_room_id"].stringValue
                                                if (chatId != ""){
                                                    let chatRef = rootRef.child("NormalChats").child(chatId)
                                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                                               "message": videoURL.absoluteString,
                                                                                               "type": 4,
                                                                                               "isRead": false,
                                                                                               "timestamp" : ServerValue.timestamp()])
                                                    
                                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                                               "message": "\(Utility.getLoginUserFullName()) shared a story with you",
                                                                                               "type": 1,
                                                                                               "isRead": false,
                                                                                               "timestamp" : ServerValue.timestamp()])
                                                    
                                                    Utility.showOrHideLoader(shouldShow: false)
                                                }
                                                else{
                                                    Loaf("Failed to create chat room", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                                    }
                                                }
                                                
                                            }
                                            else if (status == .failure){
                                                Utility.showOrHideLoader(shouldShow: false)
                                                Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                                }
                                            }
                                            else if (status == .authError){
                                                Utility.showOrHideLoader(shouldShow: false)
                                                Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                                    Utility.logoutUser()
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                else{
                                    let chatRef = rootRef.child("NormalChats").child(friend.chatId)
                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                               "message": videoURL.absoluteString,
                                                                               "type": 4,
                                                                               "isRead": false,
                                                                               "timestamp" : ServerValue.timestamp()])
                                    
                                    chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                               "senderId": "\(Utility.getLoginUserId())",
                                                                               "message": "\(Utility.getLoginUserFullName()) shared a story with you",
                                                                               "type": 1,
                                                                               "isRead": false,
                                                                               "timestamp" : ServerValue.timestamp()])
                                    
                                    Utility.showOrHideLoader(shouldShow: false)
                                }
                                
                            }
                            if (friendsArray.count > 0){
                                Loaf("Story Sent", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                    
                                }
                            }
                            
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
              //  Utility.showOrHideLoader(shouldShow: true)
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func postStory(mediaUrl: String, postType: String, caption: String){
        let params = ["media": mediaUrl,
                      "expire_hours": Utility.getLoginUserStoryExpireHours(),
                      "caption":caption,
                      "tags": tagUserIds,
                      "media_type": postType] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .createStory, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                            self.refreshHomeData()
                        })
                    }
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
    func getHomeData(){
        
        if (Reachability.isConnectedToNetwork()){
            if (followersStoriesArray.count == 0 && postsArray.count == 0){
                Utility.showOrHideLoader(shouldShow: true)
            }
            else{
                storyCollectionView.isUserInteractionEnabled = false
                carouselView.isUserInteractionEnabled = false
            }
            
            API.sharedInstance.executeAPI(type: .homePage, method: .get, params: nil) { (status, result, message) in
       
                DispatchQueue.main.async {
                    
                    Utility.showOrHideLoader(shouldShow: false)
                    
                    if (status == .success){
                        
                        UserDefaults.standard.set(result["notification_count"].intValue, forKey: "notificationCount")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
                        
                        let realm = try! Realm()
                        try! realm.safeWrite {
                            
                            //----------STORIES WORK START----------//
                            realm.delete(realm.objects(StoryUserModel.self))
                            realm.delete(realm.objects(UserStoryModel.self))
                            
                            if (result["my_stories"].arrayValue).count > 0{
                                let myStoryModel = StoryUserModel()
                                myStoryModel.updateModelWithJSON(json: result, isForMyStory: true, isPublicStory: false)
                                let myStories = Array(myStoryModel.userStories)
                                if let _ = myStories.firstIndex(where: {$0.isStoryViewed == 0}){
                                    myStoryModel.isAllStoriesViewed = false
                                }
                                else{
                                    myStoryModel.isAllStoriesViewed = true
                                }
                                if let lastMyStory = myStories.last{
                                    myStoryModel.lastStoryMediaType = lastMyStory.storyMediaType
                                    myStoryModel.lastStoryPreview = lastMyStory.storyURL
                                }
                                realm.add(myStoryModel)
                            }
                            
                            let followersStories = result["user_stories"].arrayValue
                            for followerStory in followersStories{
                                let followerStoryModel = StoryUserModel()
                                followerStoryModel.updateModelWithJSON(json: followerStory, isForMyStory: false, isPublicStory: false)
                                let followerStories = Array(followerStoryModel.userStories)
                                if let _ = followerStories.firstIndex(where: {$0.isStoryViewed == 0}){
                                    followerStoryModel.isAllStoriesViewed = false
                                }
                                else{
                                    followerStoryModel.isAllStoriesViewed = true
                                }
                                if let lastFollowerStory = followerStories.last{
                                    followerStoryModel.lastStoryMediaType = lastFollowerStory.storyMediaType
                                    followerStoryModel.lastStoryPreview = lastFollowerStory.storyURL
                                }
                                realm.add(followerStoryModel)
                            }
                            
                            //----------STORIES WORK END----------//
                            
                            
                            //----------POSTS WORK START----------//
                            realm.delete(realm.objects(HomePostsModel.self))
                            let posts = result["posts"].arrayValue
                            for post in posts{
                                let model = HomePostsModel()
                                model.updateModelWithJSON(json: post)
                                realm.add(model)
                            }
                            //----------POSTS WORK END----------//
                        }
                        self.myStoryArray = StoryUserModel.getMyStory()
                        self.followersStoriesArray = StoryUserModel.getFollowersUsersStories()
                        self.postsArray = HomePostsModel.getAllHomePosts()
                        self.storyCollectionView.reloadData()
                        self.carouselView.reloadData()
                        self.storyCollectionView.isUserInteractionEnabled = true
                        self.carouselView.isUserInteractionEnabled = true
                        
                        if (self.isFromPush){
                            let alertVC = UIAlertController(title: self.pushTitle, message: self.pushDesc, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Set Trends", style: .default) { (action) in
                            }
                            alertVC.addAction(okAction)
                            self.present(alertVC, animated: true, completion: nil)
                            self.isFromPush = false
                        }
                        
                        if (result["setting_version"].intValue != Utility.getLoginUserSettingVersion()){
                            self.getUserSettings()
                        }
                        
                    }
                    else if (status == .blockByAdmin){
                        let alertVC = UIAlertController(title: "Activity Blocked", message: "This action was blocked by admin. Please try again later. We restrict certain content and actions to protect our community. Tell us if you think we made a mistake. Email us at support@ifollowapp.com.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                            DispatchQueue.main.async {
                                Utility.logoutUser()
                            }
                        }
                        alertVC.addAction(okAction)
                        self.present(alertVC, animated: true, completion: nil)
                    }
                    else if (status == .failure){
                        
                        Utility.showOrHideLoader(shouldShow: false)
                        Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            self.myStoryArray = StoryUserModel.getMyStory()
                            self.followersStoriesArray = StoryUserModel.getFollowersUsersStories()
                            self.postsArray = HomePostsModel.getAllHomePosts()
                            self.storyCollectionView.reloadData()
                            self.carouselView.reloadData()
                            self.storyCollectionView.isUserInteractionEnabled = true
                            self.carouselView.isUserInteractionEnabled = true
                        }
                        
                    }
                    else if (status == .authError){
                        
                        Utility.showOrHideLoader(shouldShow: false)
                        Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            Utility.logoutUser()
                        }
                        
                    }
                    
                }
            }
        }
        else{
            self.myStoryArray = StoryUserModel.getMyStory()
            self.followersStoriesArray = StoryUserModel.getFollowersUsersStories()
            self.postsArray = HomePostsModel.getAllHomePosts()
            self.storyCollectionView.reloadData()
            self.carouselView.reloadData()
            self.storyCollectionView.isUserInteractionEnabled = true
            self.carouselView.isUserInteractionEnabled = true
        }
    }
    
    func getUserSettings(){
        
        API.sharedInstance.executeAPI(type: .getSetting, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                
                if (status == .success){
                    
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        let settingData = result["data"]
                        if let model = UserModel.getCurrentUser(){
                            model.userPostExpireHours = settingData["post_hours"].intValue
                            model.userStoryExpireHours = settingData["story_hours"].intValue
                            model.isUserPostViewEnable = settingData["post_view"].intValue
                            model.isUserStoryViewEnable = settingData["story_view"].intValue
                            model.userSettingVersion = settingData["version"].intValue
                            model.userProfileStatus = settingData["profile_status"].stringValue
                            model.userTrendStatus = settingData["trend_status"].stringValue
                        }
                    }
//
                }
                else if (status == .authError){
                    
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                    
                }
                
            }
            
        }
    }
    
    func updateDeviceToken(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            var deviceToken = ""
            if let token = UserDefaults.standard.value(forKey: "DeviceToken"){
                deviceToken = token as! String
                
                let params = ["mobile_id": deviceToken]
                API.sharedInstance.executeAPI(type: .updateDeviceToken, method: .post, params: params, completion: { (success, result, message) in
                    
                })
            }
        }
        
    }
    
    func goLive(){
        
        Utility.showOrHideLoader(shouldShow: true)
        var roomID = Utility.getLoginUserId()
        let timeStamp = Date().timeIntervalSince1970.rounded()
        roomID = roomID + Int(exactly: timeStamp)!
        let params = ["room_id": roomID]
        
        API.sharedInstance.executeAPI(type: .liveStreaming, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.settings.roomName = "\(roomID)"
                    self.settings.role = .broadcaster
                    self.settings.frameRate = .fps30
                    self.settings.dimension = AgoraVideoDimension1280x720
                    let vc = Utility.getLiveRoomController()
                    vc.liveRoomName = "\(roomID)"
                    vc.dataSource = self
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (status == .failure){
                    
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    
                }
                else if (status == .authError){
                    
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                    
                }
                
            }
            
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setHomeScreenColor()
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (followersStoriesArray.count > 0){
            if (followersStoriesArray.first!.isInvalidated || followersStoriesArray.last!.isInvalidated){
                return 0
            }
            else{
                return followersStoriesArray.count + 1
            }
        }
        else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCollectionViewCell
        cell.delegate = self
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.layer.borderWidth = 2
        
        if (indexPath.row == 0){
            cell.userImage.isHidden = true
            cell.addIcon.isHidden = false
            
            if (myStoryArray.count == 1){
                cell.storyImage.sd_setImage(with: URL(string: myStoryArray[indexPath.row].lastStoryPreview))
            }
            else{
                cell.storyImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()))
            }
        }
        else{
            let storyUser = followersStoriesArray[indexPath.row - 1]
            
            cell.userImage.isHidden = false
            cell.addIcon.isHidden = true
            cell.userImage.layer.borderColor = storyUser.isAllStoriesViewed ? UIColor.white.cgColor : Theme.profileLabelsYellowColor.cgColor
            cell.userImage.sd_setImage(with: URL(string: storyUser.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
            cell.storyImage.sd_setImage(with: URL(string: storyUser.lastStoryPreview))
        }
        
        return cell
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath.row == 0){
            if (myStoryArray.count > 0){
                let vc = Utility.getStoriesViewController()
                vc.isForMyStory = true
                vc.isForPublicStory = false
                vc.storyUserIndex = 0
                let navVC = UINavigationController(rootViewController: vc)
                navVC.isNavigationBarHidden = true
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
            }
        }
        else{
            let vc = Utility.getStoriesViewController()
            vc.isForMyStory = false
            vc.isForPublicStory = false
            vc.isFromExplore = true
            vc.storyUserIndex = indexPath.row - 1
            let navVC = UINavigationController(rootViewController: vc)
            navVC.isNavigationBarHidden = true
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: nil)
        }
   
    }
    
}

extension HomeViewController: StoryCollectionViewCellDelegate{
    func addStoryButtonTapped() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let liveAction = UIAlertAction(title: "Go Live", style: .default) { (action) in
            DispatchQueue.main.async {
                self.goLive()
            }
        }
        let storyAction = UIAlertAction(title: "Add Story", style: .default) { (action) in
            DispatchQueue.main.async {
                self.openCamera()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(liveAction)
        alert.addAction(storyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension HomeViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        emptyStateView.isHidden = (postsArray.count > 0)
        if (postsArray.count > 0){
            if (postsArray.first!.isInvalidated || postsArray.last!.isInvalidated){
                return 0
            }
            else{
                var addsCount = 0
                if (postsArray.count > 10){
                    addsCount = postsArray.count / 10
                }
                return postsArray.count + addsCount
            }
        }
        else{
            return 0
        }
        
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        let addView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: self, options: nil)?.first! as! GADUnifiedNativeAdView
        
        addView.frame = view.frame
        
        if (index % 10 == 0 && index != 0){
            
            view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white
            view.clipsToBounds = true
            view.addSubview(addView)
            
            nativeAdView = addView
            adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
                                   adTypes: [ .unifiedNative ], options: nil)
            adLoader.delegate = self
            adLoader.load(GADRequest())
            
            return view
        }
        else{
            itemView.index = index - (index / 10)
            let post = postsArray[index - (index / 10)]
            
            if (!postsArray.first!.isInvalidated && !postsArray.last!.isInvalidated){
                itemView.verifiedIcon.isHidden = post.isPostUserVerified == 0
                            itemView.postLinkView.isHidden = post.postBoostLink == ""
                            itemView.lblUsername.text = post.postUserFullName
                            if (post.isBoostPost){
                                itemView.lblTime.text = "SPONSORED"
                                itemView.lblTime.textColor = Theme.profileLabelsYellowColor
                                itemView.lblTime.font = Theme.getLatoBoldFontOfSize(size: 11)
                            }
                            else{
                                itemView.lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: post.postTime))
                                itemView.lblTime.textColor = Theme.feedsViewTimeColor
                                itemView.lblTime.font = Theme.getLatoRegularFontOfSize(size: 10)
                            }
                            itemView.userImage.sd_setImage(with: URL(string: post.postUserImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
                            itemView.userImage.layer.cornerRadius = itemView.userImage.frame.height / 2
                            itemView.lblUserAddress.text = post.postLocation
                            itemView.userImage.layer.cornerRadius = 25
                            if (post.postMediaType == "image"){
                                itemView.postStatusView.isHidden = true
                                itemView.feedImage.isHidden = false
                                itemView.feedImage.sd_setImage(with: URL(string: post.postMedia), placeholderImage: UIImage(named: "photo_placeholder"))
                                itemView.playIcon.isHidden = true
                            }
                            else if (post.postMediaType == "video"){
                                itemView.postStatusView.isHidden = true
                                itemView.feedImage.isHidden = false
                                itemView.feedImage.image = UIImage(named: "photo_placeholder")
                                itemView.playIcon.isHidden = false
                //                Utility.getThumbnailImageFromVideoUrl(url: URL(string: post.postMedia)!) { (thumbnailImage) in
                //                    itemView.feedImage.image = thumbnailImage
                //                }
                            }
                            else{
                                itemView.postStatusView.isHidden = false
                                itemView.feedImage.isHidden = true
                                itemView.lblPostStatus.text = post.postDescription
                            }
                            itemView.feedImage.clipsToBounds = true
                            itemView.feedImage.contentMode = .scaleAspectFill
                            itemView.lblLikeComments.text = "\(post.postLikes)"
                            itemView.likeImage.image = UIImage(named: post.isPostLike == 1 ? "like-2" : "like-1")
                //            if (post.isPostLike == 1){
                //                itemView.likeButton.setSelected(selected: true, animated: true)
                //            }
                //            else{
                //                itemView.likeButton.setSelected(selected: false, animated: false)
                //            }
                            itemView.postTagIcon.isHidden = post.postTags == ""
                            itemView.postTagIcon.isUserInteractionEnabled = true
                            itemView.postTagIcon.tag = index - (index / 10)
                            itemView.postTagIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postTagIconTapped(_:))))
                            itemView.userImage.isUserInteractionEnabled = true
                            itemView.userImage.tag = index - (index / 10)
                            itemView.userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped(_:))))
                            itemView.feedBackView.isUserInteractionEnabled = true
                            itemView.feedBackView.tag = index - (index / 10)
                            itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped(_:))))
                            itemView.postlikeView.isHidden = post.shouldShowPostTrends == 1
                            itemView.lblLikeComments.isHidden = post.shouldShowPostTrends == 1
                            itemView.postTrendLikeIcon.isHidden = post.shouldShowPostTrends == 1
                            itemView.postlikeView.isUserInteractionEnabled = true
                            itemView.postlikeView.tag = index - (index / 10)
                            itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped(_:))))
                            itemView.likeView.isUserInteractionEnabled = true
                            itemView.likeView.tag = index - (index / 10)
                            itemView.likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeViewTapped(_:))))
                            itemView.frame = view.frame
                            itemView.userImage.layer.cornerRadius = 25
                            itemView.feedImage.clipsToBounds = true
                            itemView.mainView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
                            itemView.mainView.layer.cornerRadius = 10
                            itemView.btnOptions.tag = index - (index / 10)
                            itemView.btnOptions.addTarget(self, action: #selector(showOptionsPopup(sender:)), for: .touchUpInside)
                            itemView.postShareView.tag = index - (index / 10)
                            itemView.postShareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareViewTapped(_:))))
                            itemView.postHideView.tag = index - (index / 10)
                            itemView.postHideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideViewTapped(_:))))
                            itemView.postLinkView.tag = index - (index / 10)
                            itemView.postLinkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkViewTapped(_:))))
                            view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white
                            view.clipsToBounds = true
                            view.addSubview(itemView)
            }
            
            return view
        }
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        if (index % 10 == 0 && index != 0){
        }
        else{
            let post = postsArray[index - (index / 10)]
            
            if (post.postMediaType == "image"){
                let image = LightboxImage(imageURL: URL(string: post.postMedia)!, text: post.postDescription, videoURL: nil)
                let vc = LightboxController(images: [image], startIndex: 0)
                vc.pageDelegate = self
                vc.modalPresentationStyle = .currentContext
                vc.dismissalDelegate = self
                vc.dynamicBackground = true
                self.present(vc, animated: true, completion: nil)
            }
            else if (post.postMediaType == "video"){
                let playerVC = MobilePlayerViewController()
                playerVC.setConfig(contentURL: URL(string: post.postMedia)!)
                playerVC.title = post.postDescription
                playerVC.shouldAutoplay = true
                playerVC.activityItems = [URL(string: post.postMedia)!]
                self.present(playerVC, animated: true, completion: nil)
            }
            else{
                let vc = Utility.getStatusPostDetailController()
                vc.status = post.postDescription
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func postTagIconTapped(_ sender: UITapGestureRecognizer){
        let vc = Utility.getViewersViewController()
        vc.isForTag = true
      //  vc.numberOfTrends = postsArray[sender.view!.tag].postLikes
        vc.postId = postsArray[sender.view!.tag].postId
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func userImageTapped(_ sender: UITapGestureRecognizer) {
        let vc = Utility.getOtherUserProfileViewController()
        vc.userId = postsArray[sender.view!.tag].postUserId
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func feedbackViewTapped(_ sender: UITapGestureRecognizer){
        let post = postsArray[sender.view!.tag]
        if (post.isPublicComment == 1){
            let vc = Utility.getPostCommentController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.navigationBar.isHidden = true
            vc.postId = post.postId
            vc.postUserId = post.postUserId
            self.present(navVC, animated: true, completion: nil)
        }
        else{
            let vc = Utility.getCommentViewController()
            vc.postId = post.postId
            vc.postUserId = post.postUserId
            vc.postUserImage = post.postUserImage
            vc.postUserName = post.postUserFullName
            vc.postUserLocation = post.postLocation
            vc.postUserMedia = post.postMedia
            vc.postType = post.postMediaType
            vc.postCaption = post.postDescription
            isFullScreen = true
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @objc func shareViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let trendersActions = UIAlertAction(title: "Share with Trendees", style: .default) { (action) in
            DispatchQueue.main.async {
                let vc = Utility.getShareViewController()
                vc.postId = self.postsArray[self.optionsPopupIndex].postId
                vc.postUserId = self.postsArray[self.optionsPopupIndex].postUserId
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        let myPostAction = UIAlertAction(title: "Share as My Post", style: .default) { (action) in
                
                DispatchQueue.main.async {
                    
                    Loaf("Post Shared", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    }
                    
                    let params = ["media": self.postsArray[self.optionsPopupIndex].postMedia,
                                  "description": "Original post by \(self.postsArray[self.optionsPopupIndex].postOriginalUserFullName)",
                                  "location": "",
                                  "expire_hours": Utility.getLoginUserPostExpireHours(),
                                  "duration": 0,
                                  "media_type": self.postsArray[self.optionsPopupIndex].postMediaType,
                                  "original_id": self.postsArray[self.optionsPopupIndex].postOriginalUserId,
                                  "original_name": self.postsArray[self.optionsPopupIndex].postOriginalUserFullName,
                                  "tags": [self.postsArray[self.optionsPopupIndex].postOriginalUserId],
                                  "budget": 0] as [String: Any]
                    
                    API.sharedInstance.executeAPI(type: .createPost, method: .post, params: params) { (status, result, message) in
                        DispatchQueue.main.async {
                            if (status == .authError){
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                Utility.logoutUser()
                            }
                        }
                    }
                }
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(trendersActions)
        alertVC.addAction(myPostAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc func hideViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        self.showHidePostPopup()
    }
    
    @objc func linkViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        var postLinkUrl = postsArray[optionsPopupIndex].postBoostLink
        if (postLinkUrl.contains("https://") || postLinkUrl.contains("http://")){
            
        }
        else{
            postLinkUrl = "https://\(postLinkUrl)"
        }
        if let url = URL(string: postLinkUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func likeViewTapped(_ sender: UITapGestureRecognizer){
        
        let realm = try! Realm()
        let postId = postsArray[sender.view!.tag].postId
        let postUserId = postsArray[sender.view!.tag].postUserId
        
        try! realm.safeWrite {
            if let model = realm.objects(HomePostsModel.self).filter("postId = \(postId)").first{
                model.postLikes = model.isPostLike == 0 ? model.postLikes + 1 : model.postLikes - 1
                model.isPostLike = model.isPostLike == 0 ? 1 : 0
            }
        }
        //self.carouselView.reloadItem(at: sender.view!.tag, animated: true)
        self.carouselView.reloadData()
        
        let params = ["user_id": postUserId,
                      "post_id": postId]
        
        API.sharedInstance.executeAPI(type: .likePost, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
    @objc func postLikeViewTapped(_ sender: UITapGestureRecognizer){
        let vc = Utility.getViewersViewController()
        vc.isForLike = true
        vc.numberOfTrends = postsArray[sender.view!.tag].postLikes
        vc.postId = postsArray[sender.view!.tag].postId
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func getStikcers(){
        
        if (Reachability.isConnectedToNetwork()){
            let params = ["location": userCurrentAddress,
                          "latitude": userLatitude,
                          "longitude": userLongitude] as [String: Any]
            Utility.showOrHideLoader(shouldShow: true)
            
            API.sharedInstance.executeAPI(type: .stickers, method: .get, params: params) { (status, result, message) in
                
                DispatchQueue.main.async {
                    
                    if (status == .success){
                        let realm = try! Realm()
                        try! realm.safeWrite {
                            let stickers = result["message"].arrayValue
                            realm.delete(realm.objects(StickersModel.self))
                            for sticker in stickers{
                                let model = StickersModel()
                                model.updateModelWithJSON(json: sticker)
                                realm.add(model)
                            }
                            Utility.showOrHideLoader(shouldShow: false)
                        }
                    }
                    else if (status == .failure){
                        Utility.showOrHideLoader(shouldShow: false)
                        Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            
                        }
                    }
                    else if (status == .authError){
                        Utility.showOrHideLoader(shouldShow: false)
                        Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            Utility.logoutUser()
                        }
                    }
                }
            }
        }
        
    }
}

extension HomeViewController: OptionsViewControllerDelegate{
    func didTapOnOptions(option: String) {
        if (option == "Hide"){
            self.showHidePostPopup()
        }
        else if (option == "Share"){
            let vc = Utility.getShareViewController()
            vc.postId = self.postsArray[optionsPopupIndex].postId
            vc.postUserId = self.postsArray[optionsPopupIndex].postUserId
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if (isFullScreen){
            return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        else{
            return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        
    }
    
}

extension HomeViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

extension HomeViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        tagUserIds = selectedTagUsersArray.map{$0.userId}
        storyImage = image
        saveStoryImageToFirebase(image: storyImage, caption: caption, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
    }
    
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        tagUserIds = selectedTagUsersArray.map{$0.userId}
        saveStoryVideoToFirebase(videoURL: videoURL, caption: caption, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
    }
}

extension HomeViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        manager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            if placemarks != nil{
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let placemark = placemarks![0]
                    if let area = placemark.name, let city = placemark.locality, let country = placemark.country{
                        self.userCurrentAddress = "\(area), \(city), \(country)"
                        self.userLatitude = (placemark.location?.coordinate.latitude)!
                        self.userLongitude = (placemark.location?.coordinate.longitude)!
                        print(self.userCurrentAddress)
                        self.getStikcers()
                    }
                }
            }
            
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == CLAuthorizationStatus.denied){
            self.getStikcers()
        }
    }
    
}

extension HomeViewController: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate{
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}

extension HomeViewController : GADVideoControllerDelegate {
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        
    }
}

extension HomeViewController : GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
}

extension HomeViewController : GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAdView.nativeAd = nativeAd
        
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        
        // Deactivate the height constraint that was set when the previous video ad loaded.
        //heightConstraint?.isActive = false
        
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.mediaView?.contentMode = .scaleAspectFill
        
        // Some native ads will include a video asset, while others do not. Apps can use the
        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
        // UI accordingly.
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            // By acting as the delegate to the GADVideoController, this ViewController receives messages
            // about events in the video lifecycle.
            mediaContent.videoController.delegate = self
            
        }
        else {
            
        }
        
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
//        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
//            heightConstraint = NSLayoutConstraint(item: mediaView,
//                                                  attribute: .height,
//                                                  relatedBy: .equal,
//                                                  toItem: mediaView,
//                                                  attribute: .width,
//                                                  multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
//                                                  constant: 0)
//            heightConstraint?.isActive = true
//        }
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
    
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension HomeViewController : GADUnifiedNativeAdDelegate {
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
}

extension HomeViewController: LiveVCDataSource {
    func liveVCNeedSettings() -> Settings {
        return settings
    }
    
    func liveVCNeedAgoraKit() -> AgoraRtcEngineKit {
        return agoraKit
    }
}
