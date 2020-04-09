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
    
    var otherUserProfile = OtherUserModel()
    var isTrending = false
    var options = [String]()
    var userId = 0
    var optionsPopupIndex = 0
    var chatId = ""
    
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
        lblTrends.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        lblTrending.isUserInteractionEnabled = true
        lblTrending.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendersTapped)))
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
        options = ["Block", "Report", "Copy User Url", "Private Talk"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.getOtherUserDetail()
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
        vc.preferredContentSize = CGSize(width: 150, height: 200)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = optionsView
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func showFeedsOptionsPopup(sender: UIButton){
        
        optionsPopupIndex = sender.tag
        let vc = Utility.getOptionsViewController()
        vc.options = ["Hide", "Share"]
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func privateTalkTapped(){
        showTalkPopup()
    }
    
    @objc func trendesTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.selectedIndex = 0
        vc.firstTabTitle = "TRENDERS"
        vc.secondTabTitle = "TRENDES"
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func trendersTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.selectedIndex = 1
        vc.firstTabTitle = "TRENDERS"
        vc.secondTabTitle = "TRENDES"
        self.present(vc, animated: true, completion: nil)
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
                    let vc = Utility.getChatContainerViewController()
                    vc.isFromProfile = true
                    vc.isPrivateChat = isPrivate
                    vc.chatId = self.chatId
                    vc.userId = self.userId
                    vc.userName = self.otherUserProfile.userFullName
                    vc.chatUserImage = self.otherUserProfile.userImage
                    self.present(vc, animated: true, completion: nil)
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
                    self.otherUserProfile.userRequestStatus = "pending"
                    self.trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
                    self.trendView.backgroundColor = .clear
                    self.trendView.alpha = 1
                    self.lblTrend.text = "Untrend"
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
    
    @objc func likeViewTapped(_ sender: UITapGestureRecognizer){
        
        let postId = otherUserProfile.userPosts[sender.view!.tag].postId
        let postUserId = userId
        
        let model = otherUserProfile.userPosts[sender.view!.tag]
        model.postLikes = model.isPostLike == 0 ? model.postLikes + 1 : model.postLikes - 1
        model.isPostLike = model.isPostLike == 0 ? 1 : 0
        
        self.carouselView.reloadItem(at: sender.view!.tag, animated: true)
        
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
    
    func showHidePostPopup(){
        let alertVC = UIAlertController(title: "Hide Post", message: "Are you sure you want to hide this post?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["post_id": self.otherUserProfile.userPosts[self.optionsPopupIndex].postId]
                self.otherUserProfile.userPosts.remove(at: self.optionsPopupIndex)
                self.carouselView.removeItem(at: self.optionsPopupIndex, animated: true)
                Loaf("Post Hide", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                    
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

}

extension OtherUserProfileViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        emptyStateView.isHidden = (otherUserProfile.userPosts.count > 0)
        return otherUserProfile.userPosts.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        let post = otherUserProfile.userPosts[index]
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.frame = view.frame
        itemView.lblUsername.text = otherUserProfile.userFullName
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
        itemView.btnOptions.tag = index
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
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
            vc.dismissalDelegate = self
            vc.dynamicBackground = true
            self.present(vc, animated: true, completion: nil)
        }
        else{
            let player = AVPlayer(url: URL(string: post.postMedia)!)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
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
        else if (option == "Hide"){
            self.showHidePostPopup()
        }
    }
}

extension OtherUserProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
        
    }
    
}
