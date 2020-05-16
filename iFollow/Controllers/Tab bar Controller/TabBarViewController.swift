//
//  TabBarViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import FirebaseStorage
import Firebase

class TabBarViewController: UIViewController {

    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var homeTab: UIView!
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var homeSelectedView: UIView!
    
    @IBOutlet weak var searchTab: UIView!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchSelectedView: UIView!
    
    @IBOutlet weak var cameraTab: UIView!
    
    @IBOutlet weak var notificationTab: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationSelectedView: UIView!
    
    @IBOutlet weak var profileTab: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileSelectedView: UIView!
    @IBOutlet weak var lblNotificationsCount: UILabel!
    @IBOutlet weak var lblMessagesCount: UILabel!
    
    var selectedIndex = 0
    var storageRef: StorageReference?
    var storyImage = UIImage()
    
    var homeController = UIViewController()
    var exploreController = UIViewController()
    var notificationController = UIViewController()
    var profileController = UIViewController()
    
    var allChatsArray = [RecentChatsModel]()
    var allPrivateChatsArray = [RecentChatsModel]()
    
    var normalChatRef = rootRef
    var privateChatRef = rootRef
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.dropShadow(color: .white)
       
        homeTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(homeTabTapped)))
        searchTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchTabTapped)))
        cameraTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraTabTapped)))
        notificationTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationTabTapped)))
        profileTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTabTapped)))
        
        homeController = Utility.getHomeViewController()
        exploreController = Utility.getExploreViewController()
        notificationController = Utility.getNotificationViewController()
        profileController = Utility.getProfileViewController()
        
        changeTab()
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        lblNotificationsCount.layer.masksToBounds = true
        lblNotificationsCount.layer.cornerRadius = lblNotificationsCount.frame.height / 2
        
        lblMessagesCount.layer.masksToBounds = true
        lblMessagesCount.layer.cornerRadius = lblMessagesCount.frame.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutUser), name: NSNotification.Name("logoutUser"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNotificationsCount), name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessagesCounterAfterReadChat), name: NSNotification.Name(rawValue: "updateMessagesCounterAfterReadChat"), object: nil)
        UserDefaults.standard.set(0, forKey: "messagesCount")
        normalChatRef = normalChatRef.child("NormalChats")
        privateChatRef = privateChatRef.child("PrivateChats")
        getChatList()
        getPrivateChatList()
        
    }
    
    //MARK:- Methods
    
    @objc func updateMessagesCounterAfterReadChat(){
        UserDefaults.standard.set(0, forKey: "messagesCount")
//        normalChatRef.removeAllObservers()
//        privateChatRef.removeAllObservers()
//        getChatList()
//        getPrivateChatList()
        self.setMessagesCount()
    }
    
    @objc func logoutUser(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func setNotificationsCount(){
        var notificationCount = 0
        if let count = UserDefaults.standard.value(forKey: "notificationCount"){
            notificationCount = count as! Int
        }
        lblNotificationsCount.isHidden = notificationCount == 0
        lblNotificationsCount.text = "\(notificationCount)"
    }
    
    @objc func setMessagesCount(){
        var messagesCount = 0
        if let count = UserDefaults.standard.value(forKey: "messagesCount"){
            messagesCount = count as! Int
        }
        lblMessagesCount.isHidden = messagesCount == 0
        lblMessagesCount.text = "\(messagesCount)"
    }
    
    @objc func homeTabTapped(){
        selectedIndex = 0
        changeTab()
    }
    
    @objc func searchTabTapped(){
        selectedIndex = 1
        changeTab()
    }
    
    @objc func cameraTabTapped(){
        selectedIndex = 2
        changeTab()
    }
    
    @objc func notificationTabTapped(){
        UserDefaults.standard.set(0, forKey: "notificationCount")
        setNotificationsCount()
        selectedIndex = 3
        changeTab()
    }
    
    @objc func profileTabTapped(){
        selectedIndex = 4
        changeTab()
    }
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        vc.delegate = self
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.isNavigationBarHidden = true
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func openChatBox(){
        self.setMessagesCount()
        let vc = Utility.getChatBoxContainerViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationBar.isHidden = true
//        navigationVC.modalPresentationStyle = .overFullScreen
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func changeTab(){
        
        if (selectedIndex == 0){
            
            homeImage.image = UIImage(named: "homeSelected")
            homeSelectedView.isHidden = false
            
            searchImage.image = UIImage(named: "search")
            searchSelectedView.isHidden = true
            notificationImage.image = UIImage(named: "notification")
            notificationSelectedView.isHidden = true
            profileImage.image = UIImage(named: "profile")
            profileSelectedView.isHidden = true
            
            remove(asChildViewController: [exploreController, notificationController, profileController])
            add(asChildViewController: homeController)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHomeData"), object: nil)
            
        }
        else if (selectedIndex == 1){
            
            searchImage.image = UIImage(named: "searchSelected")
            searchSelectedView.isHidden = false
            
            homeImage.image = UIImage(named: "home")
            homeSelectedView.isHidden = true
            notificationImage.image = UIImage(named: "notification")
            notificationSelectedView.isHidden = true
            profileImage.image = UIImage(named: "profile")
            profileSelectedView.isHidden = true
            
            remove(asChildViewController: [homeController, notificationController, profileController])
            add(asChildViewController: exploreController)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDiscoverData"), object: nil)
            
        }
        else if (selectedIndex == 2){
            openChatBox()
        }
        else if (selectedIndex == 3){
            
            notificationImage.image = UIImage(named: "notificationSelected")
            notificationSelectedView.isHidden = false
            
            homeImage.image = UIImage(named: "home")
            homeSelectedView.isHidden = true
            searchImage.image = UIImage(named: "search")
            searchSelectedView.isHidden = true
            profileImage.image = UIImage(named: "profile")
            profileSelectedView.isHidden = true
            
            remove(asChildViewController: [homeController, exploreController, profileController])
            add(asChildViewController: notificationController)
            
        }
        else if (selectedIndex == 4){
            
            profileImage.image = UIImage(named: "profileSelected")
            profileSelectedView.isHidden = false
            
            homeImage.image = UIImage(named: "home")
            homeSelectedView.isHidden = true
            searchImage.image = UIImage(named: "search")
            searchSelectedView.isHidden = true
            notificationImage.image = UIImage(named: "notification")
            notificationSelectedView.isHidden = true
            
            remove(asChildViewController: [homeController, exploreController, notificationController])
            add(asChildViewController: profileController)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserPosts"), object: nil)
            
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewControllers: [UIViewController]) {
        
        for viewController in viewControllers{
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        
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
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = picRef?.putData(imageData2, metadata: metadata, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    picRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
//
                            if (isToSendMyStory){
                                self.postStory(mediaUrl: imageURL.absoluteString, postType: "image", caption: caption)
                            }
                            for friend in friendsArray{
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
            
            Utility.showOrHideLoader(shouldShow: true)
            
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
                      "caption": caption,
                      "media_type": postType] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .createStory, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
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
    
    func getChatList(){
        
        API.sharedInstance.executeAPI(type: .getNormalChatsList, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    self.allChatsArray.removeAll()
                    let chatArray = result["message"].arrayValue
                    for chat in chatArray{
                        let recentChatModel = RecentChatsModel()
                        recentChatModel.updateModelWithJSON(json: chat)
                        self.allChatsArray.append(recentChatModel)
                    }
                    self.normalChatRef.observe(.childAdded) { (chatSnapshot) in
                        if let recentChat = self.allChatsArray.first(where: {$0.chatId == chatSnapshot.key}){
                            let chatNode = self.normalChatRef.child(chatSnapshot.key)
                            chatNode.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                                
                                let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                                let message = (snapshot.childSnapshot(forPath: "message").value as! String)
                                let lastMessageIsRead = (snapshot.childSnapshot(forPath: "isRead").value as! Bool)
                                if (message != ""){
                                    if (userId == "\(Utility.getLoginUserId())"){
                                        recentChat.isRead = true
                                    }
                                    else{
                                        if (!lastMessageIsRead){
                                            if let count = UserDefaults.standard.value(forKey: "messagesCount"){
                                                UserDefaults.standard.set(count as! Int + 1, forKey: "messagesCount")
                                            }
                                            else{
                                                UserDefaults.standard.set(1, forKey: "messagesCount")
                                            }
                                            self.setMessagesCount()
                                        }
                                    }
                                }
                                
                                
                            })
                        }
                        
                    }
                    
                }
                else if (status == .failure){
                    
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
    func getPrivateChatList(){
        
        API.sharedInstance.executeAPI(type: .getPrivateChatsList, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    self.allPrivateChatsArray.removeAll()
                    let chatArray = result["message"].arrayValue
                    for chat in chatArray{
                        let recentChatModel = RecentChatsModel()
                        recentChatModel.updateModelWithJSON(json: chat)
                        self.allPrivateChatsArray.append(recentChatModel)
                    }
                    self.privateChatRef.observe(.childAdded) { (chatSnapshot) in
                        if let recentChat = self.allPrivateChatsArray.first(where: {$0.chatId == chatSnapshot.key}){
                            let chatNode = self.privateChatRef.child(chatSnapshot.key)
                            chatNode.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                                
                                let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                                let message = (snapshot.childSnapshot(forPath: "message").value as! String)
                                let lastMessageIsRead = (snapshot.childSnapshot(forPath: "isRead").value as! Bool)
                                if (message != ""){
                                    if (userId == "\(Utility.getLoginUserId())"){
                                       
                                    }
                                    else{
                                        if (!lastMessageIsRead){
                                            if let count = UserDefaults.standard.value(forKey: "messagesCount"){
                                                UserDefaults.standard.set(count as! Int + 1, forKey: "messagesCount")
                                            }
                                            else{
                                                UserDefaults.standard.set(1, forKey: "messagesCount")
                                            }
                                            self.setMessagesCount()
                                        }
                                    }
                                }
                                
                                
                            })
                        }
                        
                    }
                    
                }
                else if (status == .failure){
                    
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
}

extension TabBarViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel]) {
        storyImage = image
        self.saveStoryImageToFirebase(image: storyImage, caption: caption, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
    }
    
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel]) {
        self.saveStoryVideoToFirebase(videoURL: videoURL, caption: caption, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
    }
}
