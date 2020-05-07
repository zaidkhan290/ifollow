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
import MobilePlayer

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
    
    var userPosts = [UserPostsModel]()
    var imagePicker = UIImagePickerController()
    var isFullScreen = false
    var videoURL: URL!
    var optionsPopupIndex = 0
    
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
                    let realm = try! Realm()
                    let userData = result["message"].arrayValue.first!
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
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
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
    
    func showDeletePostPopup(){
        let alertVC = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["post_id": self.userPosts[self.optionsPopupIndex].postId]
                self.userPosts.remove(at: self.optionsPopupIndex)
                self.carouselView.removeItem(at: self.optionsPopupIndex, animated: true)
                Loaf("Post Deleted", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                    
                }
                API.sharedInstance.executeAPI(type: .deletePost, method: .post, params: params, completion: { (status, result, message) in
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
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.userImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        itemView.lblUsername.text = Utility.getLoginUserFullName()
        itemView.lblTime.text = Utility.getNotificationTime(date: Utility.getNotificationDateFrom(dateString: post.postCreatedAt))
        itemView.lblUserAddress.text = post.postLocation
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
        }
        else{
            itemView.feedImage.image = UIImage(named: "post_video")
        }
        itemView.playIcon.isHidden = true
        itemView.likeImage.image = UIImage(named: post.isPostLike == 1 ? "like-2" : "like-1")
        itemView.feedImage.contentMode = .scaleAspectFill
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.likeView.isUserInteractionEnabled = true
        itemView.likeView.tag = index
        itemView.likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeViewTapped(_:))))
        itemView.btnOptions.tag = index
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
        itemView.postShareView.tag = index - (index / 5)
        itemView.postShareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editViewTapped(_:))))
        itemView.postHideView.tag = index - (index / 5)
        itemView.postHideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteViewTapped(_:))))
        
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
            vc.dismissalDelegate = self
            vc.dynamicBackground = true
            self.present(vc, animated: true, completion: nil)
        }
        else{
            let playerVC = MobilePlayerViewController(contentURL: URL(string: post.postMedia)!)
            playerVC.title = post.postDescription
            playerVC.activityItems = [URL(string: post.postMedia)!]
            self.present(playerVC, animated: true, completion: nil)
        }
        
    }
    
    @objc func feedbackViewTapped(_ sender: UIView){
        let vc = Utility.getCommentViewController()
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
