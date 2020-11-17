//
//  CreatePost1ViewController.swift
//  iFollow
//
//  Created by BSQP on 16/11/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class CreatePost1ViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var txtViewCaption: UITextView!
    @IBOutlet weak var txtViewCaptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTextCount: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var isStatusPost = false
    var isVideo = false
    var isForEdit = false
    var videoURL: URL!
    var postSelectedImage = UIImage()
    var budget: Float = 0.0
    var totalBudget: Float = 0.0
    var tagUserIds = [Int]()
    
    var editablePostId = 0
    var editablePostText = ""
    var editablePostImage = ""
    var editablePostMediaType = ""
    var editablePostUserLocation = ""
    var isForBoostEdit = false
    var editablePostStatus = ""
    var editablePostLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setData()
    }
    
    //MARK:- Methods and Actions
    
    func setColors(){
        self.view.setColor()
        btnBack.setImage(UIImage(named: traitCollection.userInterfaceStyle == .dark ? "back" : "ArrowleftBlack"), for: .normal)
        btnContinue.setImage(UIImage(named: traitCollection.userInterfaceStyle == .dark ? "continue" : "continue_black"), for: .normal)
    }
    
    func setData(){
        
        if (isForEdit){
            txtViewCaption.text = editablePostText == "" ? "Write a caption" : editablePostText
            txtViewCaption.textColor = editablePostText == "" ? Theme.captionTextViewPlaceholderColor : UIColor.label
            lblTopTitle.text = "Edit Post"
            if (editablePostMediaType == "image"){
                postImage.sd_setImage(with: URL(string: editablePostImage))
                postImage.isHidden = false
                btnPlay.isHidden = true
                lblTextCount.isHidden = true
                isStatusPost = false
                isVideo = false
            }
            else if (editablePostMediaType == "video"){
                postImage.image = UIImage(named: "post_video")
                postImage.isHidden = false
                btnPlay.isHidden = false
                lblTextCount.isHidden = false
                isStatusPost = false
                isVideo = true
                lblTextCount.text = "\(editablePostText.count)\\40"
                videoURL = URL(string: editablePostImage)
                postImage.image = UIImage(named: "photo_placeholder")
            }
        }
        else{
            lblTopTitle.text = "Create Post"
            postImage.image = postSelectedImage
            txtViewCaption.text = "Write a caption"
            txtViewCaption.textColor = Theme.captionTextViewPlaceholderColor
            postImage.isHidden = isStatusPost
            btnPlay.isHidden = !isVideo
            lblTextCount.isHidden = !isVideo
        }
        txtViewCaption.delegate = self
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPlayTapped(_ sender: UIButton) {
        let playerVC = MobilePlayerViewController()
        playerVC.setConfig(contentURL: videoURL)
        playerVC.shouldAutoplay = true
        playerVC.activityItems = [videoURL!]
        self.present(playerVC, animated: true, completion: nil)
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton) {
        
        if (isForEdit){
            let vc = Utility.getCreatePost2Controller()
            vc.isForEdit = isForEdit
            vc.editablePostId = editablePostId
            vc.editablePostText = txtViewCaption.text == "Write a caption" ? "" : txtViewCaption.text!
            vc.editablePostImage = editablePostImage
            vc.editablePostMediaType = editablePostMediaType
            vc.editablePostUserLocation = editablePostUserLocation
            vc.isForBoostEdit = isForBoostEdit
            vc.editablePostStatus = editablePostStatus
            vc.editablePostLink = editablePostLink
            self.pushToVC(vc: vc)
        }
        else{
            let vc = Utility.getCreatePost2Controller()
            vc.isStatusPost = isStatusPost
            vc.postCaption = txtViewCaption.text == "Write a caption" ? "" : txtViewCaption.text!
            vc.isVideo = isVideo
            vc.videoURL = videoURL
            vc.postSelectedImage = postSelectedImage
            vc.budget = budget
            vc.totalBudget = totalBudget
            vc.tagUserIds = tagUserIds
            self.pushToVC(vc: vc)
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}

extension CreatePost1ViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (txtViewCaption.text == "Write a caption"){
            txtViewCaption.text = ""
        }
        txtViewCaption.textColor = UIColor.label
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (txtViewCaption.text == ""){
            txtViewCaption.text = "Write a caption"
            txtViewCaption.textColor = Theme.captionTextViewPlaceholderColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
            let size = CGSize(width: self.view.frame.width, height: .infinity)
            let estimatedsize = textView.sizeThatFits(size)
            textView.constraints.forEach { (constraints) in
                constraints.constant = estimatedsize.height
            }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (isVideo){
            let maxLength = 40
            let currentString: NSString = textView.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
            lblTextCount.text = "\(newString.length == 41 ? 40 : newString.length)\\40"
            return newString.length <= maxLength
        }
        else{
            return true
        }
        
    }
    
}
