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
    
    var userPosts = [UserPostsModel]()
    var imagePicker = UIImagePickerController()
    var isFullScreen = false
    var videoURL: URL!
    
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
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.videoMaximumDuration = 60
        imagePicker.videoQuality = .typeLow
        imagePicker.delegate = self
        getUserPosts(isAfterNewPost: false)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserPost), name: NSNotification.Name(rawValue: "refreshUserPosts"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
        vc.selectedIndex = 0
        vc.firstTabTitle = "TRENDS"
        vc.secondTabTitle = "TRENDING"
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func trendingTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.selectedIndex = 1
        vc.firstTabTitle = "TRENDS"
        vc.secondTabTitle = "TRENDING"
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func editViewTapped(){
        let vc = Utility.getEditProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func searchViewTapped(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnMenuTapped(_ sender: UIButton) {
        let vc = Utility.getMenuViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationBar.isHidden = true
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func showFeedsOptionsPopup(sender: UIButton){
        
        let vc = Utility.getOptionsViewController()
        vc.options = ["Edit", "Delete"]
        vc.isFromPostView = true
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 100, height: 100)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = sender
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

extension ProfileViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return userPosts.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        let post = userPosts[index]
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.userImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        itemView.lblUsername.text = Utility.getLoginUserFullName()
        itemView.lblUserAddress.text = Utility.getLoginUserCountry()
        itemView.feedBackView.isUserInteractionEnabled = true
        itemView.feedBackView.tag = index
        itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped(_:))))
        itemView.postlikeView.isUserInteractionEnabled = true
        itemView.postlikeView.tag = index
        itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped(_:))))
        itemView.feedImage.clipsToBounds = true
        itemView.feedImage.sd_setImage(with: URL(string: post.postMedia), placeholderImage: UIImage(named: "iFollow-white-logo-1"))
        itemView.likeImage.image = UIImage(named: "like-1")
        itemView.feedImage.contentMode = .scaleAspectFill
        itemView.playIcon.isHidden = post.postMediaType == "image"
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.btnOptions.tag = index
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
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
            let player = AVPlayer(url: URL(string: post.postMedia)!)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        
    }
    
    @objc func feedbackViewTapped(_ sender: UIView){
        let vc = Utility.getCommentViewController()
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func postLikeViewTapped(_ sender: UIView){
        let vc = Utility.getViewersViewController()
        vc.isForLike = true
        isFullScreen = false
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
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
            self.present(vc, animated: true, completion: nil)
        }
        if let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            DispatchQueue.main.async {
                if let videoScreenShot = Utility.imageFromVideo(url: video, at: 0){
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
