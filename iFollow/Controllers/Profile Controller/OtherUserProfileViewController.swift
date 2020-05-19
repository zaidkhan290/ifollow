//
//  OtherUserProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel
import Lightbox
import Loaf
import AVKit
import AVFoundation
import RealmSwift

class OtherUserProfileViewController: UIViewController, UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var lblTrend: UILabel!
    @IBOutlet weak var lblTrends: UILabel!
    @IBOutlet weak var lblPosts: UILabel!
    @IBOutlet weak var privateTalkView: UIView!
    @IBOutlet weak var trendView: UIView!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var trendsView: UIView!
    @IBOutlet weak var trendingsView: UIView!
    @IBOutlet weak var lblEmptyStateDescription: UILabel!
    @IBOutlet weak var lblNoPosts: UILabel!
    
    var otherUserProfile = OtherUserModel()
    var isTrending = false
    var options = [String]()
    var userId = 0
    var optionsPopupIndex = 0
    var chatId = ""
    var isFromStory = false
    var isPrivateProfile = false
    
    var isFromPush = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileView.roundTopCorners(radius: 30)
        privateTalkView.layer.cornerRadius = 5
        privateTalkView.layer.borderWidth = 1
        privateTalkView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        privateTalkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privateTalkTapped)))
        
        trendView.layer.cornerRadius = 5
        trendView.layer.borderWidth = 1
        trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        trendView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendViewTapped)))
        
        lblTrends.isUserInteractionEnabled = true
        trendsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        lblTrending.isUserInteractionEnabled = true
        trendingsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendersTapped)))
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
        options = ["Block", "Report"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.getOtherUserDetail()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func optionsTapped(_ sender: Any) {
        showOptionsPopup()
    }
    
    func getOtherUserDetail(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["id": userId]
        
        API.sharedInstance.executeAPI(type: .getOtherUserProfile, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    let model = OtherUserModel()
                    model.updateModelWithJSON(json: result)
                    self.otherUserProfile = model
                    self.setOtherUserData()
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.dismiss(animated: true, completion: nil)
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
    
    func setOtherUserData(){
        isPrivateProfile = otherUserProfile.userProfileStatus == "private"
        trendsView.isHidden = otherUserProfile.userTrendStatus == "private"
        trendingsView.isHidden = otherUserProfile.userTrendStatus == "private"
        lblEmptyStateDescription.text = "This account is private. You must trend \(otherUserProfile.userFullName) first."
        profileImage.sd_setImage(with: URL(string: otherUserProfile.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        lblUsername.text = otherUserProfile.userFullName
        lblUserBio.text = otherUserProfile.userBio
        lblTrends.text = "\(otherUserProfile.userTrendersCount)"
        lblTrending.text = "\(otherUserProfile.userTrendingsCount)"
        lblPosts.text = "\(otherUserProfile.userPostsCount)"
        if (otherUserProfile.userRequestStatus == ""){
            trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
            trendView.backgroundColor = .clear
            trendView.alpha = 1
            lblTrend.text = "Trend"
            lblTrend.textColor = Theme.profileLabelsYellowColor
            trendView.isUserInteractionEnabled = true
        }
        else if (otherUserProfile.userRequestStatus == "success"){
            trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
            lblTrend.text = "Trending"
            lblTrend.textColor = .white
            trendView.backgroundColor = Theme.profileLabelsYellowColor
            trendView.alpha = 1
            trendView.isUserInteractionEnabled = true
        }
        else{
            trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
            trendView.backgroundColor = .clear
            trendView.alpha = 1
            lblTrend.text = "Untrend"
            lblTrend.textColor = Theme.profileLabelsYellowColor
            trendView.isUserInteractionEnabled = true
        }
        self.carouselView.reloadData()
    }
    
    func showOptionsPopup(){
        
        let vc = Utility.getOptionsViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 150, height: 100)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = optionsView
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func showFeedsOptionsPopup(sender: UIButton){
        
        optionsPopupIndex = sender.tag
        let vc = Utility.getOptionsViewController()
        vc.options = ["Report ", "Share"]
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
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        
        if (isFromPush){
            let vc = Utility.getTabBarViewController()
            UIWINDOW!.rootViewController = vc
        }
        else{
            self.dismiss(animated: true, completion: nil)
            if (isFromStory){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userProfileDismissed"), object: nil)
            }
        }
        
    }
    
    @objc func privateTalkTapped(){
        if (isPrivateProfile){
            if (otherUserProfile.userRequestStatus == "success"){
                showTalkPopup()
            }
            else{
                showPrivateProfileError()
            }
        }
        else{
            showTalkPopup()
        }
    }
    
    @objc func trendesTapped(){
        
        if (isPrivateProfile){
            if (otherUserProfile.userRequestStatus == "success"){
                let vc = Utility.getTrendersContainerViewController()
                vc.userId = userId
                vc.username = self.otherUserProfile.userFullName
                vc.selectedIndex = 0
                vc.firstTabTitle = "TRENDERS"
                vc.secondTabTitle = "TRENDEES"
                self.present(vc, animated: true, completion: nil)
            }
            else{
                showPrivateProfileError()
            }
        }
        else{
            let vc = Utility.getTrendersContainerViewController()
            vc.userId = userId
            vc.username = self.otherUserProfile.userFullName
            vc.selectedIndex = 0
            vc.firstTabTitle = "TRENDERS"
            vc.secondTabTitle = "TRENDEES"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @objc func trendersTapped(){
        
        if (isPrivateProfile){
            if (otherUserProfile.userRequestStatus == "success"){
                let vc = Utility.getTrendersContainerViewController()
                vc.userId = userId
                vc.username = self.otherUserProfile.userFullName
                vc.selectedIndex = 1
                vc.firstTabTitle = "TRENDERS"
                vc.secondTabTitle = "TRENDEES"
                self.present(vc, animated: true, completion: nil)
            }
            else{
                showPrivateProfileError()
            }
        }
        else{
            let vc = Utility.getTrendersContainerViewController()
            vc.userId = userId
            vc.username = self.otherUserProfile.userFullName
            vc.selectedIndex = 1
            vc.firstTabTitle = "TRENDERS"
            vc.secondTabTitle = "TRENDEES"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @objc func trendViewTapped(){
        if (otherUserProfile.userRequestStatus == ""){
            sendTrendRequest()
        }
        else{
            showUnTrendPopup()
        }
    }
    
    func showTalkPopup(){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let normalTalk = UIAlertAction(title: "Normal Talk", style: .default) { (action) in
            DispatchQueue.main.async {
                self.createChatRoom(isPrivate: false)
            }
        }
        let privateTalk = UIAlertAction(title: "Private Talk", style: .default) { (action) in
            DispatchQueue.main.async {
                self.createChatRoom(isPrivate: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(normalTalk)
        alertVC.addAction(privateTalk)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func createChatRoom(isPrivate: Bool){
        
        let params = ["user_id": userId,
                      "is_private": isPrivate ? 1 : 0]
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .createChatRoom, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.chatId = result["chat_room_id"].stringValue
                    if (self.chatId != ""){
                        let vc = Utility.getChatContainerViewController()
                        vc.isFromProfile = true
                        vc.isPrivateChat = isPrivate
                        vc.chatId = self.chatId
                        vc.userId = self.userId
                        vc.userName = self.otherUserProfile.userFullName
                        vc.chatUserImage = self.otherUserProfile.userImage
                        self.present(vc, animated: true, completion: nil)
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
    
    func showBlockUserPopup(){
        let vc = UIAlertController(title: "Block", message: "Are you sure you want to block \(otherUserProfile.userFullName)?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: true)
                let params = ["user_id": self.userId]
                API.sharedInstance.executeAPI(type: .blockUser, method: .post, params: params, completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        Utility.showOrHideLoader(shouldShow: false)
                        if (status == .success){
                            Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                self.dismiss(animated: true, completion: nil)
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
                })
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func showReportUserPopup(){
        let vc = UIAlertController(title: "Report", message: "Are you sure you want to report \(otherUserProfile.userFullName)?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                self.showReportDescriptionPopup()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func showReportDescriptionPopup(){
        let vc = UIAlertController(title: "Report Description", message: "Please enter your description", preferredStyle: .alert)
        vc.addTextField { (textfield) in
            textfield.placeholder = "Description"
            textfield.autocorrectionType = .no
            textfield.autocapitalizationType = .sentences
        }
        let yesAction = UIAlertAction(title: "Report", style: .default) { (action) in
            DispatchQueue.main.async {
                
                guard let textField = vc.textFields?.first else { return }
                if (textField.text == ""){
                    Loaf("Please enter reason", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    return
                }
                Utility.showOrHideLoader(shouldShow: true)
                let params = ["user_id": self.userId,
                              "options": "",
                              "description": textField.text!] as [String : Any]
                API.sharedInstance.executeAPI(type: .reportUser, method: .post, params: params, completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        Utility.showOrHideLoader(shouldShow: true)
                        if (status == .success){
                            Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                self.dismiss(animated: true, completion: nil)
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
                })
            }
        }
        let noAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func sendTrendRequest(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["user_id": userId]
        API.sharedInstance.executeAPI(type: .trendRequest, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    if (self.isPrivateProfile){
                        self.otherUserProfile.userRequestStatus = result["status"].stringValue
                        self.trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
                        self.trendView.backgroundColor = .clear
                        self.trendView.alpha = 1
                        self.lblTrend.text = "Untrend"
                        self.lblTrend.textColor = Theme.profileLabelsYellowColor
                        self.trendView.isUserInteractionEnabled = true
                    }
                    else{
                        self.otherUserProfile.userRequestStatus = result["status"].stringValue
                        self.trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
                        self.lblTrend.text = "Trending"
                        self.lblTrend.textColor = .white
                        self.trendView.backgroundColor = Theme.profileLabelsYellowColor
                        self.trendView.alpha = 1
                        self.trendView.isUserInteractionEnabled = true
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
    
    func showUnTrendPopup(){
        let vc = UIAlertController(title: "Untrend", message: "Are you sure you want to untrend \(otherUserProfile.userFullName)?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                self.untrendUser()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func untrendUser(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["user_id": userId]
        API.sharedInstance.executeAPI(type: .untrendUser, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.otherUserProfile.userRequestStatus = ""
                    self.trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
                    self.trendView.backgroundColor = .clear
                    self.trendView.alpha = 1
                    self.lblTrend.text = "Trend"
                    self.lblTrend.textColor = Theme.profileLabelsYellowColor
                    self.trendView.isUserInteractionEnabled = true
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
    
    @objc func postLikeViewTapped(_ sender: UITapGestureRecognizer){
        let vc = Utility.getViewersViewController()
        vc.isForLike = true
        vc.numberOfTrends = otherUserProfile.userPosts[sender.view!.tag].postLikes
        vc.postId = otherUserProfile.userPosts[sender.view!.tag].postId
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func feedbackViewTapped(_ sender: UITapGestureRecognizer){
        let post = otherUserProfile.userPosts[sender.view!.tag]
        let vc = Utility.getCommentViewController()
        vc.postId = post.postId
        vc.postUserId = self.userId
        vc.postUserImage = self.otherUserProfile.userImage
        vc.postUserName = self.otherUserProfile.userFullName
        vc.postUserLocation = post.postLocation
        vc.postUserMedia = post.postMedia
        vc.postType = post.postMediaType
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func likeViewTapped(_ sender: UITapGestureRecognizer){
        
        let postId = otherUserProfile.userPosts[sender.view!.tag].postId
        let postUserId = userId
        
        let model = otherUserProfile.userPosts[sender.view!.tag]
        model.postLikes = model.isPostLike == 0 ? model.postLikes + 1 : model.postLikes - 1
        model.isPostLike = model.isPostLike == 0 ? 1 : 0
        
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
    
    @objc func shareViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let trendersActions = UIAlertAction(title: "Share with Trenders", style: .default) { (action) in
            DispatchQueue.main.async {
                let vc = Utility.getShareViewController()
                vc.postId = self.otherUserProfile.userPosts[self.optionsPopupIndex].postId
                vc.postUserId = self.userId
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        let myPostAction = UIAlertAction(title: "Share as My Post", style: .default) { (action) in
                
                DispatchQueue.main.async {
                    
                    Loaf("Post Shared", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    }
                    
                    let params = ["media": self.otherUserProfile.userPosts[self.optionsPopupIndex].postMedia,
                                  "description": "",
                                  "location": "",
                                  "expire_hours": Utility.getLoginUserPostExpireHours(),
                                  "duration": 0,
                                  "media_type": self.otherUserProfile.userPosts[self.optionsPopupIndex].postMediaType,
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
    
    func showHidePostPopup(){
        let alertVC = UIAlertController(title: "Report Post", message: "Are you sure you want to report this post?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["post_id": self.otherUserProfile.userPosts[self.optionsPopupIndex].postId]
                self.otherUserProfile.userPosts.remove(at: self.optionsPopupIndex)
                self.carouselView.removeItem(at: self.optionsPopupIndex, animated: true)
                Loaf("Post Reported", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                    
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
    
    func showPrivateProfileError(){
        Loaf("This account is private. You must trend \(otherUserProfile.userFullName) first.", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

}

extension OtherUserProfileViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        if (isPrivateProfile){
            if (otherUserProfile.userRequestStatus == "success"){
                emptyStateView.isHidden = (otherUserProfile.userPosts.count > 0)
                lblEmptyStateDescription.isHidden = true
                return otherUserProfile.userPosts.count
            }
            else{
                emptyStateView.isHidden = false
                lblNoPosts.isHidden = true
                lblEmptyStateDescription.isHidden = false
                return 0
            }
        }
        else{
            emptyStateView.isHidden = (otherUserProfile.userPosts.count > 0)
            lblEmptyStateDescription.isHidden = true
            return otherUserProfile.userPosts.count
        }
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        let post = otherUserProfile.userPosts[index]
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.frame = view.frame
        itemView.lblUsername.text = otherUserProfile.userFullName
        itemView.lblTime.text = Utility.getNotificationTime(date: Utility.getNotificationDateFrom(dateString: post.postCreatedAt))
        itemView.userImage.sd_setImage(with: URL(string: otherUserProfile.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        itemView.userImage.layer.cornerRadius = itemView.userImage.frame.height / 2
        itemView.lblUserAddress.text = post.postLocation
        itemView.userImage.layer.cornerRadius = 25
        if (post.postMediaType == "image"){
            itemView.feedImage.sd_setImage(with: URL(string: post.postMedia), placeholderImage: UIImage(named: "photo_placeholder"))
        }
        else{
            itemView.feedImage.image = UIImage(named: "post_video")
        }
        itemView.playIcon.isHidden = true
        itemView.lblLikeComments.text = "\(post.postLikes)"
        itemView.feedImage.clipsToBounds = true
        itemView.feedImage.contentMode = .scaleAspectFill
        itemView.likeImage.image = UIImage(named: post.isPostLike == 1 ? "like-2" : "like-1")
//        if (post.isPostLike == 1){
//            itemView.likeButton.setSelected(selected: true, animated: true)
//        }
//        else{
//            itemView.likeButton.setSelected(selected: false, animated: false)
//        }
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.likeView.isUserInteractionEnabled = true
        itemView.likeView.tag = index
        itemView.likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeViewTapped(_:))))
        itemView.postlikeView.isHidden = post.shouldShowPostTrends == 1
        itemView.lblLikeComments.isHidden = post.shouldShowPostTrends == 1
        itemView.postTrendLikeIcon.isHidden = post.shouldShowPostTrends == 1
        itemView.postlikeView.isUserInteractionEnabled = true
        itemView.postlikeView.tag = index
        itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped(_:))))
        itemView.feedBackView.isUserInteractionEnabled = true
        itemView.feedBackView.tag = index
        itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped(_:))))
        itemView.btnOptions.tag = index
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
        itemView.postShareView.tag = index
        itemView.postShareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareViewTapped(_:))))
        itemView.postHideView.tag = index
        itemView.postHideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideViewTapped(_:))))
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let post = otherUserProfile.userPosts[index]
        
        if (post.postMediaType == "image"){
            let image = LightboxImage(imageURL: URL(string: post.postMedia)!, text: post.postDescription, videoURL: nil)
            let vc = LightboxController(images: [image], startIndex: 0)
            vc.pageDelegate = self
            vc.modalPresentationStyle = .currentContext
            vc.dismissalDelegate = self
            vc.dynamicBackground = true
            self.present(vc, animated: true, completion: nil)
        }
        else{
            let playerVC = MobilePlayerViewController()
            playerVC.setConfig(contentURL: URL(string: post.postMedia)!)
            playerVC.title = post.postDescription
            playerVC.shouldAutoplay = true
            playerVC.activityItems = [URL(string: post.postMedia)!]
            self.present(playerVC, animated: true, completion: nil)
        }
        
    }
    
}

extension OtherUserProfileViewController: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate{
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}

extension OtherUserProfileViewController: OptionsViewControllerDelegate{
    func didTapOnOptions(option: String) {
        if (option == "Block"){
            self.showBlockUserPopup()
        }
        else if (option == "Report"){
            self.showReportUserPopup()
        }
        else if (option == "Report "){
            self.showHidePostPopup()
        }
        else if (option == "Share"){
            let vc = Utility.getShareViewController()
            vc.postId = self.otherUserProfile.userPosts[optionsPopupIndex].postId
            vc.postUserId = self.userId
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension OtherUserProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
        
    }
    
}
