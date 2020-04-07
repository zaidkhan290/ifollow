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

class StoriesViewController: UIViewController {

    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnEmoji: UIButton!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var txtFieldMessage: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var nextStoryView: UIView!
    @IBOutlet weak var prevStoryView: UIView!
    
    var videoPlayer: AVPlayer!
    var storiesUsersArray = [StoryUserModel]()
    var isVideoPlaying = false
    var startIndex = 0
    var storyUserIndex = 0
    var isForMyStory = false
    var isForSkip = false // If we are skip segment index for showing the first index as unviewed index
    
    var spb: SegmentedProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputView.layer.cornerRadius = 20
        txtFieldMessage.delegate = self
        txtFieldMessage.returnKeyType = .send
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapOnView(recognizer:)))
        longPressGesture.minimumPressDuration = 0.1
        self.hiddenView.addGestureRecognizer(longPressGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissStory))
        swipeDownGesture.direction = .down
        self.hiddenView.addGestureRecognizer(swipeDownGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
       // IQKeyboardManager.shared.enable = false
        var durationArray = [Double]()
//        for i in 0..<storiesDict.count{
//            durationArray.append(15)
//        }
        storiesUsersArray = isForMyStory ? StoryUserModel.getMyStory() : StoryUserModel.getFollowersUsersStories()
        
        lblUsername.text = storiesUsersArray[storyUserIndex].userName
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.sd_setImage(with: URL(string: storiesUsersArray[storyUserIndex].userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        
        spb = SegmentedProgressBar(numberOfSegments: storiesUsersArray[storyUserIndex].userStories.count, duration: 15)
        spb.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 20, width: view.frame.width - 30, height: 4)
        view.addSubview(spb)
        
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.gray
        spb.padding = 2
        let storiesArray = Array(storiesUsersArray[storyUserIndex].userStories)
        if (!isForMyStory){
            if (!storiesUsersArray[storyUserIndex].isAllStoriesViewed){
                startIndex = storiesArray.firstIndex{$0.isStoryViewed == 0}!
            }
        }
        self.setStory(storyModel: storiesArray[startIndex], isFirstStory: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        IQKeyboardManager.shared.enable = true
    }
    
    //MARK:- Methods and Actions
    
    func setStory(storyModel: UserStoryModel, isFirstStory: Bool){
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
            self.videoView.isHidden = false
            self.imageView.isHidden = true
            self.videoPlayer = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: self.videoPlayer)
            playerLayer.frame = self.videoView.frame
            self.videoView.layer.addSublayer(playerLayer)
            Utility.showOrHideLoader(shouldShow: false)
            
            if (!self.isForMyStory){
                API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId], completion: { (status, result, message) in
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
            
            self.videoPlayer.play()
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
            Alamofire.request(storyModel.storyURL).downloadProgress(closure : { (progress) in
                print(progress.fractionCompleted)
                Utility.showOrHideLoader(shouldShow: true)
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
                        API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId], completion: { (status, result, message) in
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
                    self.videoView.layer.addSublayer(playerLayer)
                    Utility.showOrHideLoader(shouldShow: false)
                    self.videoPlayer.play()
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
                self.imageView.image = downloadedImage
                self.isVideoPlaying = false
                
                if (!self.isForMyStory){
                    API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId], completion: { (status, result, message) in
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
                        API.sharedInstance.executeAPI(type: .viewStory, method: .post, params: ["post_id": storyModel.storyId], completion: { (status, result, message) in
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
        }
        
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        
        spb.isPaused = true
        videoPlayer.pause()
        let vc = Utility.getSendStoryViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func btnEmojiTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnViewTapped(_ sender: UIButton) {
//        spb.isPaused = true
//        videoPlayer.pause()
//        let vc = Utility.getViewersViewController()
//        vc.delegate = self
//        vc.modalPresentationStyle = .custom
//        vc.transitioningDelegate = self
//        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnOptionsTapped(_ sender: UIButton) {
    }
   
    @objc func dismissStory(){
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHomeDataAfterViewedStory"), object: nil)
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
    
    func animateToNextUserStory(vc: UIViewController){
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeInOut)
        UIView.setAnimationTransition(UIView.AnimationTransition.flipFromRight, for: (self.navigationController?.view)!, cache: false)
        self.navigationController?.pushViewController(vc, animated: true)
        UIView.commitAnimations()
    }
    
}

extension StoriesViewController: SegmentedProgressBarDelegate{
    
    func segmentedProgressBarChangedIndex(index: Int) {
        
        if (!isForSkip){
            self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            self.imageView.image = nil
            self.imageView.backgroundColor = .black
            let storiesArray = Array(storiesUsersArray[storyUserIndex].userStories)
            self.setStory(storyModel: storiesArray[index], isFirstStory: false)
        }
        
    }
    
    func segmentedProgressBarFinished() {
        
        if (isForMyStory){
            self.dismissStory()
        }
        else{
            let nextUserIndex = storyUserIndex + 1
            if (self.storiesUsersArray.count - nextUserIndex == 0){
               self.dismissStory()
            }
            else{
                let vc = Utility.getStoriesViewController()
                vc.isForMyStory = false
                vc.storyUserIndex = nextUserIndex
                self.animateToNextUserStory(vc: vc)
            }
        }
        
    }
    
}

extension StoriesViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
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
        return false
    }
    
}
