//
//  StoriesViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import ARKit
import IQKeyboardManagerSwift
import Alamofire
import SDWebImage
import Loaf
import Firebase
import GoogleMobileAds

class StoriesViewController: UIViewController {

    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnTags: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnEmoji: UIButton!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var txtFieldMessage: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var userVerifiedIcon: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var nextStoryView: UIView!
    @IBOutlet weak var prevStoryView: UIView!
    @IBOutlet weak var lblStoryCaption: UILabel!
    @IBOutlet weak var btnViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSendWidthConstraint: NSLayoutConstraint!
    
    var videoPlayer: AVPlayer!
    var storiesUsersArray = [StoryUserModel]()
    var isVideoPlaying = false
    var startIndex = 0
    var storyUserIndex = 0
    var isForMyStory = false
    var isForPublicStory = false
    var isForSkip = false // If we are skip segment index for showing the first index as unviewed index
    var currentUserId = 0
    var currentUserName = ""
    var currentStoryId = 0
    var currentStoryMedia = ""
    var currentStoryMediaType = ""
    
    var spb: SegmentedProgressBar!
    var isFromExplore = false
    var interstitial: GADInterstitial!
    var loadedAddIndex = 0
    var allStoriesToDownload = [UserStoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        interstitial = createAndLoadInterstitial()
        
        messageInputView.layer.cornerRadius = 20
        setupColors()
        txtFieldMessage.delegate = self
        txtFieldMessage.returnKeyType = .send
        btnOptions.isHidden = !isForMyStory
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapOnView(recognizer:)))
        longPressGesture.minimumPressDuration = 0.1
        self.hiddenView.addGestureRecognizer(longPressGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissStory))
        swipeDownGesture.direction = .down
        self.hiddenView.addGestureRecognizer(swipeDownGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpForKeyboard))
        swipeUpGesture.direction = .up
        self.hiddenView.addGestureRecognizer(swipeUpGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(backToPrevUserStory))
        swipeRightGesture.direction = .right
        self.hiddenView.addGestureRecognizer(swipeRightGesture)
        self.prevStoryView.addGestureRecognizer(swipeRightGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(goToNextUserStory))
        swipeLeftGesture.direction = .left
        self.hiddenView.addGestureRecognizer(swipeLeftGesture)
        self.nextStoryView.addGestureRecognizer(swipeLeftGesture)
        
        lblUsername.isUserInteractionEnabled = true
        lblUsername.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userNameTapped)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userNameTapped)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            var durationArray = [Double]()
            //        for i in 0..<storiesDict.count{
            //            durationArray.append(15)
            //        }
            if (self.isForMyStory){
                self.storiesUsersArray = StoryUserModel.getMyStory()
                self.messageInputView.isHidden = true
                self.txtFieldMessage.isHidden = true
            }
            else{
                self.storiesUsersArray = self.isForPublicStory ? StoryUserModel.getPublicUsersStories() : StoryUserModel.getFollowersUsersStories()
                self.messageInputView.isHidden = false
                self.txtFieldMessage.isHidden = false
            }
            
            self.currentUserId = self.storiesUsersArray[self.storyUserIndex].userId
            self.currentUserName = self.storiesUsersArray[self.storyUserIndex].userName
            self.lblUsername.text = self.storiesUsersArray[self.storyUserIndex].userName
            self.userVerifiedIcon.isHidden = self.storiesUsersArray[self.storyUserIndex].isUserVerified == 0
            self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
            self.userImage.layer.borderWidth = 2
            self.userImage.layer.borderColor = UIColor.white.cgColor
            self.userImage.sd_setImage(with: URL(string: self.storiesUsersArray[self.storyUserIndex].userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
            
            var durations = [TimeInterval]()
            for duration in self.storiesUsersArray[self.storyUserIndex].userStories{
                if (duration.storyMediaType == "video"){
                    durations.append(61)
                }
                else{
                    durations.append(10)
                }
            }
            
            self.spb = SegmentedProgressBar(numberOfSegments: self.storiesUsersArray[self.storyUserIndex].userStories.count, durationArrValues: durations)
            self.spb.frame = CGRect(x: 15, y: self.view.safeAreaInsets.top + 20, width: self.view.frame.width - 30, height: 4)
            self.view.addSubview(self.spb)
            
            self.spb.delegate = self
            self.spb.topColor = UIColor.clear//UIColor.white
            self.spb.bottomColor = UIColor.clear//UIColor.gray
            self.spb.padding = 2
            let storiesArray = Array(self.storiesUsersArray[self.storyUserIndex].userStories)
            for story in storiesArray{
                self.allStoriesToDownload.append(story)
            }
            self.downloadAllStoriesAtBackground()
            if (!self.isForMyStory){
                if (self.storiesUsersArray[self.storyUserIndex].userProfileStatus == "private"){
                    self.btnSend.isHidden = true
                    self.btnSendWidthConstraint.constant = 35
                    self.view.updateConstraintsIfNeeded()
                    self.view.layoutSubviews()
                    
                }
                if (!self.storiesUsersArray[self.storyUserIndex].isAllStoriesViewed){
                    self.startIndex = storiesArray.firstIndex{$0.isStoryViewed == 0}!
                }
            }
            self.setStory(storyModel: storiesArray[self.startIndex], isFirstStory: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileDismissed), name: NSNotification.Name(rawValue: "userProfileDismissed"), object: nil)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(storyVideoFinish), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        IQKeyboardManager.shared.enable = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    //MARK:- Methods and Actions
    
    func setupColors(){
        self.messageInputView.setColor()
        self.messageInputView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
      var interstitial = GADInterstitial(adUnitID: interstitialAddUnitID)
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }
    
    func setStory(storyModel: UserStoryModel, isFirstStory: Bool){
        lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: storyModel.storyTime))
        lblStoryCaption.text = storyModel.storyCaption
        currentStoryId = storyModel.storyId
        currentStoryMedia = storyModel.storyURL
        currentStoryMediaType = storyModel.storyMediaType
        btnTags.isHidden = storyModel.storyTags == ""
        btnView.isHidden = isForMyStory ? false : storyModel.shouldShowStoryViews == 1
        if (isForMyStory){
            btnViewWidthConstraint.constant = 35
        }
        else{
            btnViewWidthConstraint.constant = storyModel.shouldShowStoryViews == 1 ? 0 : 35
        }
        self.view.updateConstraintsIfNeeded()
        self.view.layoutSubviews()
        if (storyModel.storyMediaType == "video"){
            self.downloadVideo(storyModel: storyModel, isFirstStory: isFirstStory)
        }
        else{
            self.downloadPhoto(storyModel: storyModel, isFirstStory: isFirstStory)
        }
    }
    
    func downloadVideo(storyModel: UserStoryModel, isFirstStory: Bool){
        
        if (!isFirstStory){
            self.spb.isPaused = true
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = documentsURL.appendingPathComponent("\(storyModel.storyId).mp4")
        if (try? Data(contentsOf: videoURL)) != nil{
            
            if (!self.isForMyStory){
                API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId, "user_id": currentUserId], completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        if (status == .authError){
                            Utility.showOrHideLoader(shouldShow: false)
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                Utility.logoutUser()
                            }
                        }
                    }
                })
            }
            
            self.videoView.isHidden = false
            self.imageView.isHidden = true
            self.videoPlayer = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: self.videoPlayer)
            playerLayer.frame = self.videoView.frame
            
            let width = self.videoPlayer.currentItem?.asset.tracks.filter{$0.mediaType == .video}.first?.naturalSize.width.rounded()
            let height = self.videoPlayer.currentItem?.asset.tracks.filter{$0.mediaType == .video}.first?.naturalSize.height.rounded()
            if (width != nil && height != nil){
                if (Int(width!) > Int(height!)){
                    playerLayer.videoGravity = .resizeAspect
                }
                else{
                    playerLayer.videoGravity = .resizeAspectFill
                }
            }
            else{
                playerLayer.videoGravity = .resizeAspectFill
            }
            self.videoView.layer.addSublayer(playerLayer)
            Utility.showOrHideLoader(shouldShow: false)
            
            let videoItem = self.videoPlayer.currentItem!
            let totalDuration = videoItem.duration.seconds
            self.videoPlayer.play()
            self.videoPlayer.isMuted = false
        
            self.isVideoPlaying = true
            if (isFirstStory){
                self.spb.startAnimation()
                for i in 0..<self.startIndex{
                    self.isForSkip = true
                    self.spb.skip()
                }
                self.isForSkip = false
                self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
            }
            self.spb.isPaused = false
        }
        else{
            
            if (isFirstStory){
                self.spb.startAnimation()
                for i in 0..<self.startIndex{
                    self.isForSkip = true
                    self.spb.skip()
                }
                self.spb.isPaused = true
                self.isForSkip = false
                self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
            }
            
            Utility.showOrHideLoader(shouldShow: true)
            Alamofire.request(storyModel.storyURL).downloadProgress(closure : { (progress) in
                print(progress.fractionCompleted)
               // Utility.showOrHideLoader(shouldShow: true)
            }).responseData{ (response) in
                print(response)
                print(response.result.value!)
                print(response.result.description)
                if let data = response.result.value {
                    
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let videoURL = documentsURL.appendingPathComponent("\(storyModel.storyId).mp4")
                    do {
                        try data.write(to: videoURL)
                    } catch {
                        Loaf("Something went wrong", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1), completionHandler: { (dimsiss) in
                            self.dismissStory()
                        })
                    }

                    if (!self.isForMyStory){
                        API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId, "user_id": self.currentUserId], completion: { (status, result, message) in
                            DispatchQueue.main.async {
                                if (status == .authError){
                                    Utility.showOrHideLoader(shouldShow: false)
                                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                        Utility.logoutUser()
                                    }
                                }
                            }
                        })
                    }

                    self.videoView.isHidden = false
                    self.imageView.isHidden = true
                    self.videoPlayer = AVPlayer(url: videoURL)
                    let playerLayer = AVPlayerLayer(player: self.videoPlayer)
                    playerLayer.frame = self.videoView.frame
                    let width = self.videoPlayer.currentItem?.asset.tracks.filter{$0.mediaType == .video}.first?.naturalSize.width.rounded()
                    let height = self.videoPlayer.currentItem?.asset.tracks.filter{$0.mediaType == .video}.first?.naturalSize.height.rounded()
                    if (width != nil && height != nil){
                        if (Int(width!) > Int(height!)){
                            playerLayer.videoGravity = .resizeAspect
                        }
                        else{
                            playerLayer.videoGravity = .resizeAspectFill
                        }
                    }
                    else{
                        playerLayer.videoGravity = .resizeAspectFill
                    }
                    self.videoView.layer.addSublayer(playerLayer)
                    Utility.showOrHideLoader(shouldShow: false)
                    
                    let videoItem = self.videoPlayer.currentItem!
                    let totalDuration = videoItem.duration.seconds
                    
                    self.videoPlayer.play()
                    self.videoPlayer.isMuted = false
                  
                    self.isVideoPlaying = true
                    self.spb.isPaused = false
                }
            }
        }
        
    }
    
    func downloadPhoto(storyModel: UserStoryModel, isFirstStory: Bool){
        
        if (!isFirstStory){
            self.spb.isPaused = true
        }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoURL = documentsURL.appendingPathComponent("\(storyModel.storyId).jpg")
        if (try? Data(contentsOf: photoURL)) != nil{
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            if let downloadedImageData = try? Data(contentsOf: photoURL){
                let downloadedImage = UIImage(data: downloadedImageData)
                
                if (!self.isForMyStory){
                    API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId, "user_id": currentUserId], completion: { (status, result, message) in
                        DispatchQueue.main.async {
                            if (status == .authError){
                                Utility.showOrHideLoader(shouldShow: false)
                                Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                    Utility.logoutUser()
                                }
                            }
                        }
                    })
                }
                
                self.imageView.image = downloadedImage
                self.isVideoPlaying = false
                
                if (isFirstStory){
                    self.spb.startAnimation()
                    for i in 0..<self.startIndex{
                        self.isForSkip = true
                        self.spb.skip()
                    }
                    self.isForSkip = false
                    self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                    self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
                }
                self.spb.isPaused = false
            }
            
        }
        else{
            
            if (isFirstStory){
                self.spb.startAnimation()
                for i in 0..<self.startIndex{
                    self.isForSkip = true
                    self.spb.skip()
                }
                self.spb.isPaused = true
                self.isForSkip = false
                self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
            }
            
            Utility.showOrHideLoader(shouldShow: true)
            
            SDWebImageDownloader.shared.downloadImage(with: URL(string: storyModel.storyURL)) { (image, data, error, success) in
                
                if (error == nil){
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let photoURL = documentsURL.appendingPathComponent("\(storyModel.storyId).jpg")
                    do {
                        try data!.write(to: photoURL)
                    } catch {
                        Loaf("Something went wrong", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1), completionHandler: { (dimsiss) in
                            self.dismissStory()
                        })
                    }
                    
                    if (!self.isForMyStory){
                        API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId, "user_id": self.currentUserId], completion: { (status, result, message) in
                            DispatchQueue.main.async {
                                if (status == .authError){
                                    Utility.showOrHideLoader(shouldShow: false)
                                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                        Utility.logoutUser()
                                    }
                                }
                            }
                        })
                    }
                    
                    Utility.showOrHideLoader(shouldShow: false)
                    self.videoView.isHidden = true
                    self.imageView.isHidden = false
                    self.imageView.image = image
                    self.isVideoPlaying = false
                    self.spb.isPaused = false
                    
                }
            }
        }
        
    }
    
    func downloadAllStoriesAtBackground(){
        allStoriesToDownload.removeFirst()
        if let story = allStoriesToDownload.first{
            if (story.storyMediaType == "video"){
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent("\(story.storyId).mp4")
                if (try? Data(contentsOf: videoURL)) == nil{
                    Alamofire.request(story.storyURL).downloadProgress(closure : { (progress) in
                        print(progress.fractionCompleted)
                       // Utility.showOrHideLoader(shouldShow: true)
                    }).responseData{ (response) in
                        print(response)
                        if let data = response.result.value {
                            
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let videoURL = documentsURL.appendingPathComponent("\(story.storyId).mp4")
                            do {
                                try data.write(to: videoURL)
                            } catch {
                                
                            }
                            self.downloadAllStoriesAtBackground()
                        }
                    }
                }
                else{
                    self.downloadAllStoriesAtBackground()
                }
                
            }
            else{
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let photoURL = documentsURL.appendingPathComponent("\(story.storyId).jpg")
                if (try? Data(contentsOf: photoURL)) == nil{
                    
                    SDWebImageDownloader.shared.downloadImage(with: URL(string: story.storyURL)) { (image, data, error, success) in
                        
                        if (error == nil){
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let photoURL = documentsURL.appendingPathComponent("\(story.storyId).jpg")
                            do {
                                try data!.write(to: photoURL)
                            } catch {
                                
                            }
                            self.downloadAllStoriesAtBackground()
                        }
                    }
                    
                }
                else{
                    self.downloadAllStoriesAtBackground()   
                }
            }
        }
    }
    
    @IBAction func btnTagsTapped(_ sender: UIButton){
        spb.isPaused = true
        if (isVideoPlaying){
            videoPlayer.pause()
        }
        let vc = Utility.getViewersViewController()
        vc.postId = currentStoryId
        vc.isForStoryTag = true
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        
        spb.isPaused = true
        if (isVideoPlaying){
            videoPlayer.pause()
        }
        let vc = Utility.getSendStoryViewController()
        vc.currentUserId = self.currentUserId
        vc.currentUserName = self.currentUserName
        vc.currentStoryId = self.currentStoryId
        vc.currentStoryMedia = self.currentStoryMedia
        vc.currentStoryMediaType = self.currentStoryMediaType
        vc.isForOthersStory = !isForMyStory
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func btnEmojiTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnViewTapped(_ sender: UIButton) {
        spb.isPaused = true
        if (isVideoPlaying){
            videoPlayer.pause()
        }
        let vc = Utility.getViewersViewController()
        vc.postId = currentStoryId
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnOptionsTapped(_ sender: UIButton) {
        showOptionsPopup()
    }
    
    func showOptionsPopup(){
        
        spb.isPaused = true
        if (isVideoPlaying){
            videoPlayer.pause()
        }
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteStoryAction = UIAlertAction(title: "Delete Story", style: .default) { (action) in
            DispatchQueue.main.async {
                self.showDeleteStoryPopup()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            DispatchQueue.main.async {
                self.spb.isPaused = false
                if (self.isVideoPlaying){
                    self.videoPlayer.play()
                }
            }
        }
        alertVC.addAction(deleteStoryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showDeleteStoryPopup(){
        let alertVC = UIAlertController(title: "Delete Story", message: "Are you sure you want to delete this story?", preferredStyle: .alert)
        let deleteStoryAction = UIAlertAction(title: "Delete Story", style: .default) { (action) in
            DispatchQueue.main.async {
                
                let params = ["story_id": self.currentStoryId]
                Utility.showOrHideLoader(shouldShow: true)
                API.sharedInstance.executeAPI(type: .deleteStory, method: .post, params: params, completion: { (status, result, message) in
                    
                    DispatchQueue.main.async {
                        Utility.showOrHideLoader(shouldShow: false)
                        
                        if (status == .success){
                            Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                self.dismissStory()
                            }
                            
                        }
                        else if (status == .failure){
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                
                            }
                            self.spb.isPaused = false
                            if (self.isVideoPlaying){
                                self.videoPlayer.play()
                            }
                        }
                        else if (status == .authError){
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                Utility.logoutUser()
                            }
                        }
                    }
                    
                })
                
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            DispatchQueue.main.async {
                self.spb.isPaused = false
                if (self.isVideoPlaying){
                    self.videoPlayer.play()
                }
            }
        }
        alertVC.addAction(deleteStoryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
   
    @objc func dismissStory(){
        if (isVideoPlaying){
            self.videoPlayer.pause()
        }
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHomeDataAfterViewedStory"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDiscoverDataAfterViewedStory"), object: nil)
        
    }
    
    @objc func swipeUpForKeyboard(){
        if (!isForMyStory){
            txtFieldMessage.becomeFirstResponder()
        }
    }
    
    @objc func nextStory(){
        if (isVideoPlaying){
            self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            self.videoPlayer.pause()
        }
        isForSkip = false
        self.spb.skip()
    }
    
    @objc func prevStory(){
        if (isVideoPlaying){
            self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            self.videoPlayer.pause()
        }
        isForSkip = false
        self.spb.rewind()
    }
    
    @objc func storyVideoFinish(){
        self.nextStory()
    }
    
    @objc func tapOnView(recognizer: UILongPressGestureRecognizer){
        if (recognizer.state == .began){
            spb.isPaused = true
            if (isVideoPlaying){
                videoPlayer.pause()
            }
        }
        else if (recognizer.state == .ended){
            spb.isPaused = false
            if (isVideoPlaying){
                videoPlayer.play()
            }
            
        }
    }
    
    @objc func userNameTapped(){
        if (!isForMyStory){
            spb.isPaused = true
            if (isVideoPlaying){
                videoPlayer.pause()
            }
            let vc = Utility.getOtherUserProfileViewController()
            vc.userId = currentUserId
            vc.isFromStory = true
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func userProfileDismissed() {
        if (isVideoPlaying){
            videoPlayer.play()
        }
        spb.isPaused = false
    }
    
    func sendCommentOnStory(){
        if (txtFieldMessage.text != ""){
            
            Utility.showOrHideLoader(shouldShow: true)
            let params = ["user_id": currentUserId,
                          "is_private": 0]
            
            API.sharedInstance.executeAPI(type: .createChatRoom, method: .post, params: params) { (status, result, message) in
                
                DispatchQueue.main.async {
                    Utility.showOrHideLoader(shouldShow: false)
                    
                    if (status == .success){
                        let chatId = result["chat_room_id"].stringValue
                        if (chatId != ""){
                            
                            let chatRef = rootRef.child("NormalChats").child(chatId)
                            
                            let timeStamp = ServerValue.timestamp()
                            
                            chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                            "senderId": "\(Utility.getLoginUserId())",
                                "message": self.currentStoryMedia,
                                "type": self.currentStoryMediaType == "image" ? 2 : 4,
                                "isRead": false,
                                "timestamp" : timeStamp])
                            
                            chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                            "senderId": "\(Utility.getLoginUserId())",
                                "message": "\(Utility.getLoginUserFullName()) left feedback on your story: \(self.txtFieldMessage.text!)",
                                "type": 1,
                                "isRead": false,
                                "timestamp" : timeStamp])
                            
                            self.sendPushNotification(chatId: chatId)
                            
                            Loaf("Feedback sent", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                self.txtFieldMessage.text = ""
                            }
                            
                        }
                        else{
                            Loaf("Failed to add comment", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
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
    }
    
    func sendPushNotification(chatId: String){
        let params = ["user_id": self.currentUserId,
                      "alert": "\(Utility.getLoginUserFullName()) left feedback on your story",
            "name": Utility.getLoginUserFullName(),
            "data": "\(Utility.getLoginUserFullName()) left feedback on your story",
            "tag": 12,
            "chat_room_id": chatId] as [String: Any]
        API.sharedInstance.executeAPI(type: .sendPushNotification, method: .post, params: params) { (status, result, message) in
            
        }
    }
    
    func animateToNextUserStory(vc: UIViewController){
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationCurve(UIView.AnimationCurve.linear)
        UIView.setAnimationTransition(UIView.AnimationTransition.flipFromRight, for: (self.navigationController?.view)!, cache: false)
        self.navigationController?.pushViewController(vc, animated: true)
        UIView.commitAnimations()
    }
    
    @objc func goToNextUserStory(){
        
        if (!isForMyStory){
            
            if (isVideoPlaying){
                self.videoPlayer.pause()
            }
            
            let nextUserIndex = storyUserIndex + 1
            if (self.storiesUsersArray.count - nextUserIndex == 0){
                self.dismissStory()
            }
            else{
                let vc = Utility.getStoriesViewController()
                vc.isForMyStory = false
                vc.isFromExplore = isFromExplore
                vc.isForPublicStory = isForPublicStory
                vc.storyUserIndex = nextUserIndex
                
                self.animateToNextUserStory(vc: vc)
            }
        }
    }
    
    @objc func backToPrevUserStory(){
        
        if (!isForMyStory){
            
            if (isVideoPlaying){
                self.videoPlayer.pause()
            }
           
            if (storyUserIndex > 0){
                let prevUserIndex = storyUserIndex - 1
                if (self.storiesUsersArray.count - prevUserIndex == 0){
                    self.dismissStory()
                }
                else{
                    let vc = Utility.getStoriesViewController()
                    vc.isForMyStory = false
                    vc.isFromExplore = isFromExplore
                    vc.isForPublicStory = isForPublicStory
                    vc.storyUserIndex = prevUserIndex
                    UIView.beginAnimations("", context: nil)
                    UIView.setAnimationDuration(0.5)
                    UIView.setAnimationCurve(UIView.AnimationCurve.linear)
                    UIView.setAnimationTransition(UIView.AnimationTransition.flipFromLeft, for: (self.navigationController?.view)!, cache: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                    UIView.commitAnimations()
                }
            }
            else{
                self.dismissStory()
            }
        }
        else{
            self.dismissStory()
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
    }
    
}

extension StoriesViewController: SegmentedProgressBarDelegate{
    
    func segmentedProgressBarChangedIndex(index: Int) {
        
        if (!isForSkip){
            if (isVideoPlaying){
                self.videoPlayer.pause()
            }
            self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            self.imageView.image = nil
            self.imageView.backgroundColor = .black
            let storiesArray = Array(storiesUsersArray[storyUserIndex].userStories)
            if (isFromExplore && index % 3 == 0 && loadedAddIndex != index){
                if (interstitial.isReady){
                    loadedAddIndex = index
                    interstitial.present(fromRootViewController: self)
                }
                else{
                    self.setStory(storyModel: storiesArray[index], isFirstStory: false)
                }
            }
            else{
                self.setStory(storyModel: storiesArray[index], isFirstStory: false)
            }
            
        }
        
    }
    
    func segmentedProgressBarFinished() {
        
        if (isForMyStory){
            self.dismissStory()
            if (isVideoPlaying){
                self.videoPlayer.pause()
            }
        }
        else{
            goToNextUserStory()
        }
        
    }
    
}

extension StoriesViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension StoriesViewController: SendStoryViewControllerDelegate{
    
    func sendStoryPopupDismissed() {
        if (isVideoPlaying){
            videoPlayer.play()
        }
        spb.isPaused = false
    }
}

extension StoriesViewController: ViewersControllerDelegate{
    
    func viewersPopupDismissed() {
        if (isVideoPlaying){
            videoPlayer.play()
        }
        spb.isPaused = false
    }
    
}

extension StoriesViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        spb.isPaused = true
        if (isVideoPlaying){
            videoPlayer.pause()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        sendStoryPopupDismissed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendCommentOnStory()
        return false
    }
    
}

extension StoriesViewController: GADInterstitialDelegate{
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
        DispatchQueue.main.async {
            self.spb.isPaused = true
            if (self.isVideoPlaying){
                self.videoPlayer.pause()
            }
        }
        
    }

    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
        interstitial = createAndLoadInterstitial()
        self.prevStory()
        self.nextStory()
//        DispatchQueue.main.async {
//            self.spb.isPaused = false
//            if (self.isVideoPlaying){
//                self.videoPlayer.play()
//            }
//        }
        
    }

    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
}
