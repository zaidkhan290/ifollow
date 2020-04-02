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
        
        let model1 = StoryModel()
        model1.storyId = 1
        model1.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585742103.mov?alt=media&token=5c66bb7e-6c0f-4a5f-82e6-d1402ab6357b"
        model1.storyMediaType = "video"
        storiesArray.append(model1)
        
        let model2 = StoryModel()
        model2.storyId = 2
        model2.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1584621848.jgp?alt=media&token=9b21ae6b-43df-4545-bbe1-fd38017b5fdc"
        model2.storyMediaType = "image"
        storiesArray.append(model2)

        let model3 = StoryModel()
        model3.storyId = 3
        model3.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585741866.mov?alt=media&token=015d7ed0-93bd-432c-b035-f8e42f59d822"
        model3.storyMediaType = "video"
        storiesArray.append(model3)

        let model4 = StoryModel()
        model4.storyId = 4
        model4.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585654428.jgp?alt=media&token=89487b81-bc98-422f-80d5-143b00c5fdb0"
        model4.storyMediaType = "image"
        storiesArray.append(model4)
        
        
        spb = SegmentedProgressBar(numberOfSegments: storiesArray.count, duration: 15)
        spb.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 20, width: view.frame.width - 30, height: 4)
        view.addSubview(spb)
        
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.gray
        spb.padding = 2
        
        self.setStory(storyModel: storiesArray.first!, isFirstStory: true)
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
        let story = self.storiesArray[index]
        self.setStory(storyModel: story, isFirstStory: false)
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
