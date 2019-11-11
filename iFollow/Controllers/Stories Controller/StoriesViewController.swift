//
//  StoriesViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import ARKit

class StoriesViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnEmoji: UIButton!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var txtFieldMessage: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    
    var videoPlayer: AVPlayer!
    
    var spb: SegmentedProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputView.layer.cornerRadius = 20
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapOnView(recognizer:)))
        longPressGesture.minimumPressDuration = 0.1
        self.view.addGestureRecognizer(longPressGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissStory))
        swipeDownGesture.direction = .down
        self.videoView.addGestureRecognizer(swipeDownGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        spb = SegmentedProgressBar(numberOfSegments: 3, duration: 5)
        spb.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 20, width: view.frame.width - 30, height: 4)
        view.addSubview(spb)
        
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.gray
        spb.padding = 2
        spb.startAnimation()
        
        let videoPath = Bundle.main.path(forResource: "sampleVideo", ofType: "mp4")
        let videoUrl = URL(fileURLWithPath: videoPath!)
        videoPlayer = AVPlayer(url: videoUrl)
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(playerLayer)
        videoPlayer.play()
      //  videoPlayer = AVPlayer(url: videoPath)
 
    }
    
    //MARK:- Actions
    
    @IBAction func btnOptionsTapped(_ sender: UIButton) {
    }
   
    @objc func dismissStory(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapOnView(recognizer: UILongPressGestureRecognizer){
        if (recognizer.state == .began){
            spb.isPaused = true
            videoPlayer.pause()
        }
        else if (recognizer.state == .ended){
            spb.isPaused = false
            videoPlayer.play()
        }
    }
    
    
   
}

extension StoriesViewController: SegmentedProgressBarDelegate{
    
    func segmentedProgressBarChangedIndex(index: Int) {
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.play()
    }
    
    func segmentedProgressBarFinished() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
