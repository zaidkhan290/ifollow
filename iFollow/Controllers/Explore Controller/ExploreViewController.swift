//
//  ExploreViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import FirebaseStorage
import Loaf
import RealmSwift
import Firebase

class ExploreViewController: UIViewController {

//    @IBOutlet weak var searchView: UIView!
//    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var recentStoriesCollectionView: UICollectionView!
    @IBOutlet weak var allStoriesCollectionView: UICollectionView!
    
    var imagePicker = UIImagePickerController()
    var storageRef: StorageReference?
    var storyImage = UIImage()
    
    var myStoryArray = [StoryUserModel]()
    var followersStoriesArray = [StoryUserModel]()
    var publicStoriesArray = [StoryUserModel]()
    var tagUserIds = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setExploreScreenColor()
        searchIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchViewTapped)))
        
        let storyCell = UINib(nibName: "StoryCollectionViewCell", bundle: nil)
        self.recentStoriesCollectionView.register(storyCell, forCellWithReuseIdentifier: "StoryCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 105, height: self.recentStoriesCollectionView.frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.recentStoriesCollectionView.collectionViewLayout = layout
        self.recentStoriesCollectionView.showsHorizontalScrollIndicator = false
        
        let allStoryCell = UINib(nibName: "AllStoriesCollectionViewCell", bundle: nil)
        self.allStoriesCollectionView.register(allStoryCell, forCellWithReuseIdentifier: "AllStories")
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image" /*"public.movie"*/]
        imagePicker.delegate = self
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDiscoverData), name: NSNotification.Name(rawValue: "refreshDiscoverData"), object: nil)
     //   NotificationCenter.default.addObserver(self, selector: #selector(refreshDiscoverData), name: NSNotification.Name(rawValue: "refreshDiscoverDataAfterViewedStory"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshDiscoverData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.minimumInteritemSpacing = 1
        layout2.itemSize = CGSize(width: 105, height: (self.allStoriesCollectionView.bounds.height / 2) - 5)
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.allStoriesCollectionView.collectionViewLayout = layout2
        self.allStoriesCollectionView.showsHorizontalScrollIndicator = false
    }
    
    //MARK:- Methods
    func setExploreScreenColor(){
        if (traitCollection.userInterfaceStyle == .dark){
            self.view.backgroundColor = Theme.darkModeBlackColor
        }
        else{
            self.view.backgroundColor = .white
        }
    }
    
    @objc func refreshDiscoverData(){
        getDiscoverData()
    }
    
    func getDiscoverData(){
        
        if (publicStoriesArray.count == 0){
            Utility.showOrHideLoader(shouldShow: true)
        }
        else{
            recentStoriesCollectionView.isUserInteractionEnabled = false
            allStoriesCollectionView.isUserInteractionEnabled = false
        }
        
        API.sharedInstance.executeAPI(type: .getDiscover, method: .get, params: nil) { (status, result, message) in
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
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
                        
                        let publicsStories = result["public_stories"].arrayValue
                        for publicStory in publicsStories{
                            let publicStoryModel = StoryUserModel()
                            publicStoryModel.updateModelWithJSON(json: publicStory, isForMyStory: false, isPublicStory: true)
                            let publicStories = Array(publicStoryModel.userStories)
                            if let _ = publicStories.firstIndex(where: {$0.isStoryViewed == 0}){
                                publicStoryModel.isAllStoriesViewed = false
                            }
                            else{
                                publicStoryModel.isAllStoriesViewed = true
                            }
                            if let lastPublicStory = publicStories.last{
                                publicStoryModel.lastStoryMediaType = lastPublicStory.storyMediaType
                                publicStoryModel.lastStoryPreview = lastPublicStory.storyURL
                            }
                            realm.add(publicStoryModel)
                            
                        }
                        
                        //----------STORIES WORK END----------//
                        
                    }
                    self.myStoryArray = StoryUserModel.getMyStory()
                    self.followersStoriesArray = StoryUserModel.getFollowersUsersStories()
                    self.publicStoriesArray = StoryUserModel.getPublicUsersStories()
                    self.recentStoriesCollectionView.isUserInteractionEnabled = true
                    self.allStoriesCollectionView.isUserInteractionEnabled = true
                    self.recentStoriesCollectionView.reloadData()
                    self.allStoriesCollectionView.reloadData()
              
                }
                else if (status == .failure){
                    
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.myStoryArray = StoryUserModel.getMyStory()
                        self.followersStoriesArray = StoryUserModel.getFollowersUsersStories()
                        self.recentStoriesCollectionView.isUserInteractionEnabled = true
                        self.allStoriesCollectionView.isUserInteractionEnabled = true
                        self.recentStoriesCollectionView.reloadData()
                        
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
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        vc.delegate = self
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.isNavigationBarHidden = true
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func searchViewTapped(){
        let vc = Utility.getSearchViewController()
        self.present(vc, animated: true, completion: nil)
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
            
          //  Utility.showOrHideLoader(shouldShow: true)
            
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
            //    Utility.showOrHideLoader(shouldShow: true)
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
            
         //   Utility.showOrHideLoader(shouldShow: true)
            
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
               // Utility.showOrHideLoader(shouldShow: true)
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
                      "tags": tagUserIds,
                      "media_type": postType] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .createStory, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                            self.refreshDiscoverData()
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setExploreScreenColor()
    }
}

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionView == recentStoriesCollectionView){
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
        else{
            if (publicStoriesArray.count > 0){
                if (publicStoriesArray.first!.isInvalidated || publicStoriesArray.last!.isInvalidated){
                    return 0
                }
                else{
                    return publicStoriesArray.count
                }
            }
            else{
                return 0
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == recentStoriesCollectionView){
            
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
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllStories", for: indexPath) as! AllStoriesCollectionViewCell
            
            let storyUser = publicStoriesArray[indexPath.row]
            
            cell.userImage.isHidden = false
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
            cell.userImage.layer.borderWidth = 2
            cell.storyImage.layer.cornerRadius = 5
            cell.userImage.layer.borderColor = storyUser.isAllStoriesViewed ? UIColor.white.cgColor : Theme.profileLabelsYellowColor.cgColor
            cell.lblUsername.text = storyUser.userName
            cell.lblUserStatus.text = ""
            cell.userImage.sd_setImage(with: URL(string: storyUser.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
            cell.storyImage.sd_setImage(with: URL(string: storyUser.lastStoryPreview))
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView == recentStoriesCollectionView){
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
                vc.storyUserIndex = indexPath.row - 1
                vc.isFromExplore = true
                let navVC = UINavigationController(rootViewController: vc)
                navVC.isNavigationBarHidden = true
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
            }
        }
        else{
            let vc = Utility.getStoriesViewController()
            vc.isForMyStory = false
            vc.isForPublicStory = true
            vc.storyUserIndex = indexPath.row
            vc.isFromExplore = true
            let navVC = UINavigationController(rootViewController: vc)
            navVC.isNavigationBarHidden = true
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
}

extension ExploreViewController: StoryCollectionViewCellDelegate{
    func addStoryButtonTapped() {
        openCamera()
    }
}

extension ExploreViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension ExploreViewController: PostViewControllerDelegate{
    
    func postTapped(postView: UIViewController) {
        self.view.makeToast("Your post share successfully..")
        postView.dismiss(animated: true, completion: nil)
    }
    
    func imageTapped(postView: UIViewController) {
        postView.dismiss(animated: true, completion: nil)
        searchViewTapped()
    }
}

extension ExploreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let vc = Utility.getNewPostViewController()
            vc.postSelectedImage = pickedImage
            vc.delegate = self
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ExploreViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        storyImage = image
        tagUserIds = selectedTagUsersArray.map{$0.userId}
        self.saveStoryImageToFirebase(image: storyImage, caption: caption, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
    }
    
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        tagUserIds = selectedTagUsersArray.map{$0.userId}
        self.saveStoryVideoToFirebase(videoURL: videoURL, caption: caption, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
    }
}
