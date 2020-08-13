//
//  ProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel
import Toast_Swift
import Lightbox
import RealmSwift
import Loaf
import AVKit
import AVFoundation

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userSmallImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var trendingView: UIView!
    @IBOutlet weak var trendesView: UIView!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var lblTrends: UILabel!
    @IBOutlet weak var privateTalkView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFiledSearch: UITextField!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var emptyDataView: UIView!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    var userPosts = [UserPostsModel]()
    var imagePicker = UIImagePickerController()
    var isFullScreen = false
    var videoURL: URL!
    var optionsPopupIndex = 0
    var boostPostAmount: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileView.roundTopCorners(radius: 30)
        trendingView.layer.cornerRadius = 15
        trendingView.layer.borderWidth = 1
        trendingView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        trendingView.isUserInteractionEnabled = true
        trendingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendingTapped)))
        
        trendesView.layer.cornerRadius = 15
        trendesView.layer.borderWidth = 1
        trendesView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        trendesView.isUserInteractionEnabled = true
        trendesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        
        privateTalkView.layer.cornerRadius = 5
        privateTalkView.layer.borderWidth = 1
        privateTalkView.layer.borderColor = UIColor.white.cgColor
        privateTalkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privateChatTapped)))
        
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        txtFiledSearch.isUserInteractionEnabled = false
        searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchViewTapped)))
        Utility.setTextFieldPlaceholder(textField: txtFiledSearch, placeholder: "What's in your mind?", color: Theme.searchFieldColor)
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.videoMaximumDuration = 60
        imagePicker.videoQuality = .type640x480
        imagePicker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserPost), name: NSNotification.Name(rawValue: "refreshUserPosts"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        setUserData()
    }
    
    //MARK:- Actions and Methods
    
    func setUserData(){
        profileImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        userSmallImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        userSmallImage.layer.cornerRadius = userSmallImage.frame.height / 2
        lblUsername.text = Utility.getLoginUserFullName()
        lblUserBio.text  = Utility.getLoginUserBio()
    }
    
    @objc func refreshUserPost(){
        self.getUserPosts(isAfterNewPost: false)
    }
    
    func setUserPosts(isAfterNewPost: Bool){
        
        lblTrends.text = "\(Utility.getLoginUserTrendersCount())"
        lblTrending.text = "\(Utility.getLoginUserTrendingsCount())"
        
        userPosts = UserPostsModel.getAllUserPosts()
        userPosts = userPosts.reversed()
        self.carouselView.reloadData()
        if (isAfterNewPost){
            self.carouselView.scrollToItem(at: 0, animated: true)
        }
        
    }
    
    func getUserPosts(isAfterNewPost: Bool){
        
        if (!Reachability.isConnectedToNetwork()){
            setUserPosts(isAfterNewPost: isAfterNewPost)
            return
        }
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .getMyProfile, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    
                    self.boostPostAmount = Float(result["post_amount"].stringValue)!
                    let realm = try! Realm()
                    let userData = result["message"].arrayValue.first!
                    UserDefaults.standard.set(userData["notification_count"].intValue, forKey: "notificationCount")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
                    try! realm.safeWrite {
                        if let user = UserModel.getCurrentUser(){
                            user.userTrenders = userData["trenders"].intValue
                            user.userTrendings = userData["trendings"].intValue
                            user.userPosts = userData["posts"].intValue
                        }
                        let posts = result["posts"].arrayValue
                        realm.delete(realm.objects(UserPostsModel.self))
                        for post in posts{
                            let model = UserPostsModel()
                            model.updateModelWithJSON(json: post)
                            realm.add(model)
                        }
                    }
                    self.verifiedIcon.isHidden = result["message"].arrayValue.first!["verified"].intValue == 0
                    kIsUserVerified = result["message"].arrayValue.first!["verified"].intValue == 1
                    self.setUserPosts(isAfterNewPost: isAfterNewPost)
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.setUserPosts(isAfterNewPost: isAfterNewPost)
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
    
    @objc func privateChatTapped(){
        let vc = Utility.getChatBoxContainerViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationBar.isHidden = true
        navigationVC.modalPresentationStyle = .overFullScreen
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func trendesTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.userId = Utility.getLoginUserId()
        vc.username = Utility.getLoginUserFullName()
        vc.selectedIndex = 0
        vc.firstTabTitle = "TRENDERS"
        vc.secondTabTitle = "TRENDEES"
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func trendingTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.userId = Utility.getLoginUserId()
        vc.username = Utility.getLoginUserFullName()
        vc.selectedIndex = 1
        vc.firstTabTitle = "TRENDERS"
        vc.secondTabTitle = "TRENDEES"
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func editViewTapped(){
        let vc = Utility.getEditProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func searchViewTapped(){
        
//        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
//            self.imagePicker.sourceType = .camera
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
//            self.imagePicker.sourceType = .photoLibrary
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertVC.addAction(cameraAction)
//        alertVC.addAction(galleryAction)
//        alertVC.addAction(cancelAction)
//        self.present(alertVC, animated: true, completion: nil)
        
        let vc = Utility.getCameraViewController()
        vc.isForPost = true
        vc.delegate = self
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.isNavigationBarHidden = true
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
        
    }
    
    @IBAction func btnMenuTapped(_ sender: UIButton) {
        let vc = Utility.getMenuViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationBar.isHidden = true
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func showFeedsOptionsPopup(sender: UIButton){
        
        optionsPopupIndex = sender.tag
        let vc = Utility.getOptionsViewController()
        vc.options = ["Edit", "Delete"]
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
    
    @objc func likeViewTapped(_ sender: UITapGestureRecognizer){
        
        let realm = try! Realm()
        let postId = userPosts[sender.view!.tag].postId
        let postUserId = Utility.getLoginUserId()
        
        try! realm.safeWrite {
            if let model = realm.objects(UserPostsModel.self).filter("postId = \(postId)").first{
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
    
    func showDeletePostPopup(){
        let alertVC = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["post_id": self.userPosts[self.optionsPopupIndex].postId]
                Utility.showOrHideLoader(shouldShow: true)
                
                API.sharedInstance.executeAPI(type: .deletePost, method: .post, params: params, completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        Utility.showOrHideLoader(shouldShow: false)
                        if (status == .success){
                            self.userPosts.remove(at: self.optionsPopupIndex)
                            self.carouselView.removeItem(at: self.optionsPopupIndex, animated: true)
                            Loaf("Post Deleted", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                                
                            }
                            self.carouselView.reloadData()
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
                })
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func linkViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        var postLinkUrl = self.userPosts[optionsPopupIndex].postBoostLink
        if (postLinkUrl.contains("https://") || postLinkUrl.contains("http://")){
            
        }
        else{
            postLinkUrl = "https://\(postLinkUrl)"
        }
        if let url = URL(string: postLinkUrl) {
            UIApplication.shared.open(url)
        }
    }
    
}

extension ProfileViewController: OptionsViewControllerDelegate{
    func didTapOnOptions(option: String) {
        if (option == "Delete"){
            self.showDeletePostPopup()
        }
        else if (option == "Edit"){
            let post = self.userPosts[optionsPopupIndex]
            let vc = Utility.getNewPostViewController()
            isFullScreen = true
            vc.isForEdit = true
            vc.budget = boostPostAmount
            vc.totalBudget = boostPostAmount
            vc.editablePostId = post.postId
            vc.editablePostText = post.postDescription
            vc.editablePostImage = post.postMedia
            vc.editablePostMediaType = post.postMediaType
            vc.editablePostUserLocation = post.postLocation
            vc.delegate = self
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: false, completion: nil)

        }
    }
}

extension ProfileViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        emptyDataView.isHidden = (userPosts.count > 0)
        if (userPosts.count > 0){
            if (userPosts.first!.isInvalidated || userPosts.last!.isInvalidated){
                return 0
            }
            else{
                return userPosts.count
            }
        }
        else{
            return 0
        }
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        let post = userPosts[index]
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.postLinkView.isHidden = post.postBoostLink == ""
        if (post.postStatus == "boost"){
            itemView.lblTime.text = "SPONSORED"
            itemView.lblTime.textColor = Theme.profileLabelsYellowColor
            itemView.lblTime.font = Theme.getLatoBoldFontOfSize(size: 11)
        }
        else{
            itemView.lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: post.postCreatedAt))
            itemView.lblTime.textColor = Theme.feedsViewTimeColor
            itemView.lblTime.font = Theme.getLatoRegularFontOfSize(size: 10)
        }
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.userImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        itemView.lblUsername.text = Utility.getLoginUserFullName()
        itemView.lblUserAddress.text = post.postLocation
        itemView.feedbackImageView.image = UIImage(named: "share-1")
        itemView.feedBackView.isUserInteractionEnabled = true
        itemView.feedBackView.tag = index
        itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped(_:))))
        itemView.postlikeView.isUserInteractionEnabled = true
        itemView.postlikeView.tag = index
        itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped(_:))))
        itemView.lblLikeComments.text = "\(post.postLikes)"
        itemView.feedImage.clipsToBounds = true
        if (post.postMediaType == "image"){
            itemView.feedImage.sd_setImage(with: URL(string: post.postMedia), placeholderImage: UIImage(named: "photo_placeholder"))
            itemView.playIcon.isHidden = true
        }
        else{
            itemView.feedImage.image = UIImage(named: "photo_placeholder")
            itemView.playIcon.isHidden = false
//            Utility.getThumbnailImageFromVideoUrl(url: URL(string: post.postMedia)!) { (thumbnailImage) in
//                itemView.feedImage.image = thumbnailImage
//            }
        }
        itemView.likeImage.image = UIImage(named: post.isPostLike == 1 ? "like-2" : "like-1")
//        if (post.isPostLike == 1){
//            itemView.likeButton.setSelected(selected: true, animated: true)
//        }
//        else{
//            itemView.likeButton.setSelected(selected: false, animated: false)
//        }
        itemView.feedImage.contentMode = .scaleAspectFill
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.postTagIcon.isHidden = post.postTags == ""
        itemView.postTagIcon.isUserInteractionEnabled = true
        itemView.postTagIcon.tag = index
        itemView.postTagIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postTagIconTapped(_:))))
        itemView.likeView.isUserInteractionEnabled = true
        itemView.likeView.tag = index
        itemView.likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeViewTapped(_:))))
        itemView.btnOptions.tag = index
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
        itemView.postShareImageView.image = UIImage(named: "edit-1")
        itemView.postShareView.tag = index
        itemView.postShareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editViewTapped(_:))))
        itemView.postHideImageView.image = UIImage(named: "delete-1")
        itemView.postHideView.tag = index
        itemView.postHideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteViewTapped(_:))))
        itemView.postLinkView.tag = index
        itemView.postLinkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkViewTapped(_:))))
        
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let post = userPosts[index]
        
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
    
    @objc func feedbackViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        let vc = Utility.getShareViewController()
        vc.postId = self.userPosts[optionsPopupIndex].postId
        vc.postUserId = Utility.getLoginUserId()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func postTagIconTapped(_ sender: UITapGestureRecognizer){
        let vc = Utility.getViewersViewController()
        vc.isForTag = true
       // vc.numberOfTrends = userPosts[sender.view!.tag].postLikes
        vc.postId = userPosts[sender.view!.tag].postId
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func postLikeViewTapped(_ sender: UITapGestureRecognizer){
        let vc = Utility.getViewersViewController()
        vc.isForLike = true
        vc.numberOfTrends = userPosts[sender.view!.tag].postLikes
        vc.postId = userPosts[sender.view!.tag].postId
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func editViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        let post = self.userPosts[optionsPopupIndex]
        let vc = Utility.getNewPostViewController()
        isFullScreen = true
        vc.isForEdit = true
        vc.editablePostId = post.postId
        vc.editablePostText = post.postDescription
        vc.editablePostImage = post.postMedia
        vc.editablePostMediaType = post.postMediaType
        vc.editablePostUserLocation = post.postLocation
        vc.isForBoostEdit = post.postStatus == "boost"
        vc.editablePostStatus = post.postStatus
        vc.editablePostLink = post.postBoostLink
        vc.budget = boostPostAmount
        vc.totalBudget = boostPostAmount
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: false, completion: nil)

    }
    
    @objc func deleteViewTapped(_ sender: UITapGestureRecognizer){
        optionsPopupIndex = sender.view!.tag
        self.showDeletePostPopup()
    }
    
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if (isFullScreen){
            return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        else{
            return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
    
}

extension ProfileViewController: PostViewControllerDelegate{
    
    func postTapped(postView: UIViewController) {
      //  self.view.makeToast("Your post share successfully..")
        postView.dismiss(animated: true, completion: nil)
        self.getUserPosts(isAfterNewPost: true)
    }
    
    func imageTapped(postView: UIViewController) {
        postView.dismiss(animated: true, completion: nil)
        searchViewTapped()
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let vc = Utility.getNewPostViewController()
            vc.postSelectedImage = pickedImage
            vc.isVideo = false
            isFullScreen = true
            vc.delegate = self
            vc.budget = boostPostAmount
            vc.totalBudget = boostPostAmount
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: false, completion: nil)
        }
        if let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            DispatchQueue.main.async {
                if let videoScreenShot = Utility.imageFromVideo(url: video, at: 0, totalTime: 60){
                    let vc = Utility.getNewPostViewController()
                    vc.postSelectedImage = videoScreenShot
                    vc.videoURL = video
                    vc.isVideo = true
                    vc.budget = self.boostPostAmount
                    vc.totalBudget = self.boostPostAmount
                    self.isFullScreen = true
                    vc.delegate = self
                    vc.modalPresentationStyle = .custom
                    vc.transitioningDelegate = self
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ProfileViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

extension ProfileViewController: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate{
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}

extension ProfileViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        
        let vc = Utility.getNewPostViewController()
        vc.postSelectedImage = image
        vc.isVideo = false
        isFullScreen = true
        vc.budget = boostPostAmount
        vc.tagUserIds = selectedTagUsersArray.map{$0.userId}
        vc.totalBudget = boostPostAmount
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: false, completion: nil)
        
    }
    
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        DispatchQueue.main.async {
            if let videoScreenShot = Utility.imageFromVideo(url: videoURL, at: 0, totalTime: 60){
                let vc = Utility.getNewPostViewController()
                vc.postSelectedImage = videoScreenShot
                vc.videoURL = videoURL
                vc.budget = self.boostPostAmount
                vc.totalBudget = self.boostPostAmount
                vc.isVideo = true
                vc.tagUserIds = selectedTagUsersArray.map{$0.userId}
                self.isFullScreen = true
                vc.delegate = self
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
