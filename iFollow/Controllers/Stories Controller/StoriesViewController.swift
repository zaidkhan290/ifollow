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
    var storiesArray = [StoryModel]()
    var isVideoPlaying = false
    var startIndex = 0
    
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
        
        IQKeyboardManager.shared.enable = false
        var durationArray = [Double]()
//        for i in 0..<storiesDict.count{
//            durationArray.append(15)
//        }
        
        
        spb = SegmentedProgressBar(numberOfSegments: storiesArray.count, duration: 15)
        spb.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 20, width: view.frame.width - 30, height: 4)
        view.addSubview(spb)
        
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.gray
        spb.padding = 2
        startIndex = self.storiesArray.firstIndex{$0.isWatched == false}!
        self.setStory(storyModel: storiesArray[startIndex], isFirstStory: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        IQKeyboardManager.shared.enable = true
    }
    
    //MARK:- Methods and Actions
    
    func setStory(storyModel: StoryModel, isFirstStory: Bool){
        if (storyModel.storyMediaType == "video"){
            self.downloadVideo(storyModel: storyModel, isFirstStory: isFirstStory)
        }
        else{
            self.downloadPhoto(storyModel: storyModel, isFirstStory: isFirstStory)
        }
    }
    
    func downloadVideo(storyModel: StoryModel, isFirstStory: Bool){
        
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
            self.videoPlayer.play()
            self.isVideoPlaying = true
            if (isFirstStory){
                self.spb.startAnimation()
                for i in 0..<self.startIndex{
                    self.spb.skip()
                }
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
                    print(videoURL)
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
                            self.spb.skip()
                        }
                        self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                        self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
                    }
                    self.spb.isPaused = false
                }
            }
        }
        
    }
    
    func downloadPhoto(storyModel: StoryModel, isFirstStory: Bool){
        
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
                if (isFirstStory){
                    self.spb.startAnimation()
                    for i in 0..<self.startIndex{
                        self.spb.skip()
                    }
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
                    print(photoURL)
                    
                    Utility.showOrHideLoader(shouldShow: false)
                    self.videoView.isHidden = true
                    self.imageView.isHidden = false
                    self.imageView.image = image
                    self.isVideoPlaying = false
                    if (isFirstStory){
                        self.spb.startAnimation()
                        for i in 0..<self.startIndex{
                            self.spb.skip()
                        }
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
    }
    
    @objc func nextStory(){
        if (isVideoPlaying){
            self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            self.videoPlayer.pause()
        }
        self.spb.skip()
    }
    
    @objc func prevStory(){
        if (isVideoPlaying){
            self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.videoView.isHidden = true
            self.imageView.isHidden = false
            self.videoPlayer.pause()
        }
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
        self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.videoView.isHidden = true
        self.imageView.isHidden = false
        self.imageView.image = nil
        self.imageView.backgroundColor = .black
        let story = self.storiesArray[index]
        self.setStory(storyModel: story, isFirstStory: false)
    }
    
    func segmentedProgressBarFinished() {
        
        if (storiesArray.count == 2){
            self.dismissStory()
        }
        else{
            var nextUserStories = [StoryModel]()
            let model1 = StoryModel()
            model1.storyId = 5
            model1.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585831533.jgp?alt=media&token=a13e40f2-b5a6-4e4f-a807-f8d0ceb53982"
            model1.storyMediaType = "image"
            model1.isWatched = false
            nextUserStories.append(model1)
            
            let model2 = StoryModel()
            model2.storyId = 6
            model2.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585831670.mov?alt=media&token=a41d8357-b412-44a5-993c-bb8504c17835"
            model2.storyMediaType = "video"
            model2.isWatched = false
            nextUserStories.append(model2)
            let vc = Utility.getStoriesViewController()
            vc.storiesArray = nextUserStories
            self.animateToNextUserStory(vc: vc)
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
