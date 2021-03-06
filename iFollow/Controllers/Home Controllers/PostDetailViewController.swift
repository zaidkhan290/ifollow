//
//  PostDetailViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 10/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel
import Loaf
import CoreLocation
import Lightbox
import AVKit
import AVFoundation
import RealmSwift

class PostDetailViewController: UIViewController {

    @IBOutlet weak var carouselView: iCarousel!
    var postId = 0
    var showCommentsDirectly = false
    var postsArray = [HomePostsModel]()
    var optionsPopupIndex = 0
    var isFullScreen = false
    
    var isFromPush = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupColors()
        self.carouselView.type = .rotary
        self.carouselView.isScrollEnabled = false
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        getPostDetail()
    }
    
    func setupColors(){
        self.view.setColor()
        self.carouselView.reloadData()
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        if (isFromPush){
            let vc = Utility.getTabBarViewController()
            UIWINDOW!.rootViewController = vc
        }
        else{
           self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getPostDetail(){
        let params = ["post_id": postId]
        Utility.showOrHideLoader(shouldShow: true)
        API.sharedInstance.executeAPI(type: .getPostFromNotification, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    if let postData = result["message"].arrayValue.first{
                        let realm = try! Realm()
                        try! realm.safeWrite {
                            if let model = realm.objects(HomePostsModel.self).filter("postId = \(self.postId)").first{
                                model.updateModelWithJSON(json: postData)
                                model.isBoostPost = postData["status"].stringValue == "boost"
                                self.postsArray = Array(realm.objects(HomePostsModel.self).filter("postId = \(self.postId)"))
                            }
                            else{
                                let model = HomePostsModel()
                                model.updateModelWithJSON(json: postData)
                                model.isBoostPost = postData["status"].stringValue == "boost"
                                realm.add(model)
                                self.postsArray = Array(realm.objects(HomePostsModel.self).filter("postId = \(self.postId)"))
                            }
                        }
                        self.carouselView.reloadData()
                        if (self.showCommentsDirectly){
                            self.feedbackViewTapped()
                        }
                    }
                    else{
                        Loaf("Post has been expired", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        self.dismiss(animated: true, completion: nil)
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
    
    @objc func showOptionsPopup(sender: UIButton){
        
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
    
    func showHidePostPopup(){
        let alertVC = UIAlertController(title: "Hide Post", message: "Are you sure you want to hide this post?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["post_id": self.postsArray[self.optionsPopupIndex].postId]
                self.postsArray.remove(at: self.optionsPopupIndex)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
    }
}


extension PostDetailViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return postsArray.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        view.setColor()
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.backgroundColor = .clear
        itemView.index = index
        let post = postsArray[index]
        
        itemView.lblUsername.text = post.postUserFullName
        if (post.postUserId == Utility.getLoginUserId()){
            itemView.postLinkView.isHidden = true
        }
        else{
            itemView.postLinkView.isHidden = post.postBoostLink == ""
        }
        if (post.isBoostPost){
            itemView.lblTime.text = "SPONSORED"
            itemView.lblTime.textColor = Theme.profileLabelsYellowColor
            itemView.lblTime.font = Theme.getLatoBoldFontOfSize(size: 11)
        }
        else{
            itemView.lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: post.postTime))
            itemView.lblTime.textColor = Theme.feedsViewTimeColor
            itemView.lblTime.font = Theme.getLatoRegularFontOfSize(size: 10)
        }
        
        itemView.userImage.sd_setImage(with: URL(string: post.postUserImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        itemView.userImage.layer.cornerRadius = itemView.userImage.frame.height / 2
        itemView.lblUserAddress.text = post.postLocation
        itemView.userImage.layer.cornerRadius = 25
        if (post.postMediaType == "image"){
            itemView.postStatusView.isHidden = true
            itemView.feedImage.isHidden = false
            itemView.feedImage.sd_setImage(with: URL(string: post.postMedia), placeholderImage: UIImage(named: "photo_placeholder"))
            itemView.playIcon.isHidden = true
        }
        else if (post.postMediaType == "video"){
            itemView.postStatusView.isHidden = true
            itemView.feedImage.isHidden = false
            itemView.feedImage.image = UIImage(named: "photo_placeholder")
            itemView.playIcon.isHidden = false
//                Utility.getThumbnailImageFromVideoUrl(url: URL(string: post.postMedia)!) { (thumbnailImage) in
//                    itemView.feedImage.image = thumbnailImage
//                }
        }
        else{
            itemView.postStatusView.isHidden = false
            itemView.feedImage.isHidden = true
            itemView.lblPostStatus.text = post.postDescription
        }
        itemView.feedImage.clipsToBounds = true
        itemView.feedImage.contentMode = .scaleAspectFill
        itemView.lblLikeComments.text = "\(post.postLikes)"
        itemView.likeImage.image = UIImage(named: post.isPostLike == 1 ? "like-2" : "like-1")
//        if (post.isPostLike == 1){
//            itemView.likeButton.setSelected(selected: true, animated: true)
//        }
//        else{
//            itemView.likeButton.setSelected(selected: false, animated: false)
//        }
        itemView.postTagIcon.isHidden = post.postTags == ""
        itemView.postTagIcon.isUserInteractionEnabled = true
        itemView.postTagIcon.tag = index
        itemView.postTagIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postTagIconTapped(_:))))
        itemView.userImage.isUserInteractionEnabled = true
        itemView.userImage.tag = index
        itemView.userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped(_:))))
        itemView.feedBackView.isUserInteractionEnabled = true
        itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped)))
        itemView.postlikeView.isHidden = post.postUserId == Utility.getLoginUserId() ? false : post.shouldShowPostTrends == 1
        itemView.lblLikeComments.isHidden = post.postUserId == Utility.getLoginUserId() ? false : post.shouldShowPostTrends == 1
        itemView.postTrendLikeIcon.isHidden = post.postUserId == Utility.getLoginUserId() ? false : post.shouldShowPostTrends == 1
        itemView.postlikeView.isUserInteractionEnabled = true
        itemView.postlikeView.tag = index
        itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped(_:))))
        itemView.likeView.isUserInteractionEnabled = true
        itemView.likeView.tag = index
        itemView.likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeViewTapped(_:))))
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.feedImage.clipsToBounds = true
        itemView.mainView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.btnOptions.isHidden = true
//        itemView.likeView.isHidden = post.postUserId == Utility.getLoginUserId()
//        itemView.feedBackView.isHidden = post.postUserId == Utility.getLoginUserId()
//        itemView.postShareView.isHidden = post.postUserId == Utility.getLoginUserId()
//        itemView.postHideView.isHidden = post.postUserId == Utility.getLoginUserId()
        itemView.postShareView.tag = index
        itemView.postShareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareViewTapped(_:))))
        itemView.postHideView.tag = index
        itemView.postHideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideViewTapped(_:))))
        itemView.btnOptions.tag = index
        itemView.btnOptions.addTarget(self, action: #selector(showOptionsPopup(sender:)), for: .touchUpInside)
        itemView.postLinkView.tag = index
        itemView.postLinkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkViewTapped(_:))))
        view.clipsToBounds = true
        view.setColor()
        view.addSubview(itemView)
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let post = postsArray[index]
        
        if (post.postMediaType == "image"){
            let image = LightboxImage(imageURL: URL(string: post.postMedia)!, text: post.postDescription, videoURL: nil)
            let vc = LightboxController(images: [image], startIndex: 0)
            vc.pageDelegate = self
            vc.modalPresentationStyle = .currentContext
            vc.dismissalDelegate = self
            vc.dynamicBackground = true
            self.present(vc, animated: true, completion: nil)
        }
        else if (post.postMediaType == "video"){
            let playerVC = MobilePlayerViewController()
            playerVC.setConfig(contentURL: URL(string: post.postMedia)!)
            playerVC.title = post.postDescription
            playerVC.shouldAutoplay = true
            playerVC.activityItems = [URL(string: post.postMedia)!]
            self.present(playerVC, animated: true, completion: nil)
        }
        else{
            let vc = Utility.getStatusPostDetailController()
            vc.status = post.postDescription
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    //    func userImageTapped(index: Int) {
    //        let vc = Utility.getOtherUserProfileViewController()
    //        self.present(vc, animated: true, completion: nil)
    //    }
    
    @objc func userImageTapped(_ sender: UITapGestureRecognizer) {
        let vc = Utility.getOtherUserProfileViewController()
        vc.userId = postsArray[sender.view!.tag].postUserId
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func feedbackViewTapped(){
        isFullScreen = true
        let post = postsArray.first!
        if (post.isPublicComment == 1){
            let vc = Utility.getPostCommentController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.navigationBar.isHidden = true
            vc.postId = post.postId
            vc.postUserId = post.postUserId
            self.present(navVC, animated: true, completion: nil)
        }
        else{
            let vc = Utility.getCommentViewController()
            vc.postId = post.postId
            vc.postUserId = post.postUserId
            vc.postUserImage = post.postUserImage
            vc.postUserName = post.postUserFullName
            vc.postUserLocation = post.postLocation
            vc.postUserMedia = post.postMedia
            vc.postType = post.postMediaType
            vc.postCaption = post.postDescription
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @objc func shareViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let trendersActions = UIAlertAction(title: "Share with Trendees", style: .default) { (action) in
            DispatchQueue.main.async {
                let vc = Utility.getShareViewController()
                vc.postId = self.postsArray[self.optionsPopupIndex].postId
                vc.postUserId = self.postsArray[self.optionsPopupIndex].postUserId
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        let myPostAction = UIAlertAction(title: "Share as My Post", style: .default) { (action) in
                
                DispatchQueue.main.async {
                    
                    Loaf("Post Shared", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    }
                    
                    let params = ["media": self.postsArray[self.optionsPopupIndex].postMedia,
                                  "description": "Original post by \(self.postsArray[self.optionsPopupIndex].postOriginalUserFullName)",
                                  "location": "",
                                  "expire_hours": Utility.getLoginUserPostExpireHours(),
                                  "duration": 0,
                                  "media_type": self.postsArray[self.optionsPopupIndex].postMediaType,
                                  "original_id": self.postsArray[self.optionsPopupIndex].postOriginalUserId,
                                  "original_name": self.postsArray[self.optionsPopupIndex].postOriginalUserFullName,
                                  "tags": [self.postsArray[self.optionsPopupIndex].postOriginalUserId],
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
    
    @objc func postTagIconTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        let vc = Utility.getViewersViewController()
        vc.isForTag = true
        //vc.numberOfTrends = postsArray[sender.view!.tag].postLikes
        vc.postId = postsArray[sender.view!.tag].postId
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func hideViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        self.showHidePostPopup()
    }
    
    @objc func linkViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        var postLinkUrl = postsArray[optionsPopupIndex].postBoostLink
        if (postLinkUrl.contains("https://") || postLinkUrl.contains("http://")){
            
        }
        else{
            postLinkUrl = "https://\(postLinkUrl)"
        }
        if let url = URL(string: postLinkUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func likeViewTapped(_ sender: UITapGestureRecognizer){
        
        let realm = try! Realm()
        let postId = postsArray[sender.view!.tag].postId
        let postUserId = postsArray[sender.view!.tag].postUserId
        
        try! realm.safeWrite {
            if let model = realm.objects(HomePostsModel.self).filter("postId = \(postId)").first{
                model.postLikes = model.isPostLike == 0 ? model.postLikes + 1 : model.postLikes - 1
                model.isPostLike = model.isPostLike == 0 ? 1 : 0
            }
        }
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
    
    @objc func postLikeViewTapped(_ sender: UITapGestureRecognizer){
        let vc = Utility.getViewersViewController()
        vc.isForLike = true
        vc.numberOfTrends = postsArray[sender.view!.tag].postLikes
        vc.postId = postsArray[sender.view!.tag].postId
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension PostDetailViewController: OptionsViewControllerDelegate{
    func didTapOnOptions(option: String) {
        if (option == "Hide"){
            self.showHidePostPopup()
        }
    }
}

extension PostDetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if (isFullScreen){
            return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        else{
            return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        
    }
    
}

extension PostDetailViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

extension PostDetailViewController: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate{
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
