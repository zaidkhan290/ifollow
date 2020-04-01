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
    var storiesDict = [[String:String]]()
    var isVideoPlaying = false
    
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
        
        var story1 = [String:String]()
        story1["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585742103.mov?alt=media&token=5c66bb7e-6c0f-4a5f-82e6-d1402ab6357b"
        story1["mediaType"] = "video"
        storiesDict.append(story1)

        var story2 = [String:String]()
        story2["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1584621848.jgp?alt=media&token=9b21ae6b-43df-4545-bbe1-fd38017b5fdc"
        story2["mediaType"] = "image"
        storiesDict.append(story2)

        var story3 = [String:String]()
        story3["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585741866.mov?alt=media&token=015d7ed0-93bd-432c-b035-f8e42f59d822"
        story3["mediaType"] = "video"
        storiesDict.append(story3)
        
        var story4 = [String:String]()
        story4["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585654428.jgp?alt=media&token=89487b81-bc98-422f-80d5-143b00c5fdb0"
        story4["mediaType"] = "image"
        storiesDict.append(story4)
        
        
//        var story1 = [String:String]()
//        story1["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1584621848.jgp?alt=media&token=9b21ae6b-43df-4545-bbe1-fd38017b5fdc"
//        story1["mediaType"] = "image"
//        storiesDict.append(story1)
//
//        var story2 = [String:String]()
//        story2["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585737991.jgp?alt=media&token=7225eb23-23d4-4fdf-ae30-6fe93b36915e"
//        story2["mediaType"] = "image"
//        storiesDict.append(story2)
//
//        var story3 = [String:String]()
//        story3["url"] = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585654428.jgp?alt=media&token=89487b81-bc98-422f-80d5-143b00c5fdb0"
//        story3["mediaType"] = "image"
//        storiesDict.append(story3)
        
        
        spb = SegmentedProgressBar(numberOfSegments: storiesDict.count, duration: 15)
        spb.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 20, width: view.frame.width - 30, height: 4)
        view.addSubview(spb)
        
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.gray
        spb.padding = 2
        
        let story = self.storiesDict.first!
        let storyUrl = story["url"]
        let storyType = story["mediaType"]
        self.setStory(storyURL: storyUrl!, storyType: storyType!, isFirstStory: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        IQKeyboardManager.shared.enable = true
    }
    
    //MARK:- Methods and Actions
    
    func setStory(storyURL: String, storyType: String, isFirstStory: Bool){
        if (storyType == "video"){
            self.downloadVideo(videoURL: storyURL, isFirstStory: isFirstStory)
        }
        else{
            self.downloadPhoto(photoURL: storyURL, isFirstStory: isFirstStory)
        }
    }
    
    func downloadVideo(videoURL: String, isFirstStory: Bool){
        
        if (!isFirstStory){
            self.spb.isPaused = true
        }
        Alamofire.request(videoURL).downloadProgress(closure : { (progress) in
            print(progress.fractionCompleted)
            Utility.showOrHideLoader(shouldShow: true)
        }).responseData{ (response) in
            print(response)
            print(response.result.value!)
            print(response.result.description)
            if let data = response.result.value {
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent("video.mp4")
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
                    self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                    self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
                }
                self.spb.isPaused = false
            }
        }
    }
    
    func downloadPhoto(photoURL: String, isFirstStory: Bool){
        
        Utility.showOrHideLoader(shouldShow: true)
        if (!isFirstStory){
            self.spb.isPaused = true
        }
        SDWebImageDownloader.shared.downloadImage(with: URL(string: photoURL)) { (image, data, error, success) in

            if (error == nil){
                Utility.showOrHideLoader(shouldShow: false)
                self.videoView.isHidden = true
                self.imageView.isHidden = false
                self.imageView.image = image
                self.isVideoPlaying = false
                if (isFirstStory){
                    self.spb.startAnimation()
                    self.nextStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStory)))
                    self.prevStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.prevStory)))
                }
                self.spb.isPaused = false

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
        spb.isPaused = true
        videoPlayer.pause()
        let vc = Utility.getViewersViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
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
    
}

extension StoriesViewController: SegmentedProgressBarDelegate{
    
    func segmentedProgressBarChangedIndex(index: Int) {
        self.videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.videoView.isHidden = true
        self.imageView.isHidden = false
        self.imageView.image = nil
        self.imageView.backgroundColor = .black
        let story = self.storiesDict[index]
        let storyUrl = story["url"]
        let storyType = story["mediaType"]
        self.setStory(storyURL: storyUrl!, storyType: storyType!, isFirstStory: false)
    }
    
    func segmentedProgressBarFinished() {
        self.dismissStory()
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
