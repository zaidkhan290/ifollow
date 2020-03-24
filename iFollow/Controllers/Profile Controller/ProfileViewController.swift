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

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userSmallImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var lblTrends: UILabel!
    @IBOutlet weak var lblPosts: UILabel!
    @IBOutlet weak var privateTalkView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFiledSearch: UITextField!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var trendesView: UIView!
    @IBOutlet weak var trendingView: UIView!
    
    var imagePicker = UIImagePickerController()
    var isFullScreen = false
    var videoURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileView.roundTopCorners(radius: 30)
        editView.layer.cornerRadius = 15
        editView.layer.borderWidth = 1
        editView.layer.borderColor = UIColor.black.cgColor
        editView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editViewTapped)))
        
        privateTalkView.layer.cornerRadius = 5
        privateTalkView.layer.borderWidth = 1
        privateTalkView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        privateTalkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privateChatTapped)))
        
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        txtFiledSearch.isUserInteractionEnabled = false
        searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchViewTapped)))
        Utility.setTextFieldPlaceholder(textField: txtFiledSearch, placeholder: "What's in your mind?", color: Theme.searchFieldColor)
        
        trendesView.isUserInteractionEnabled = true
        trendesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        trendingView.isUserInteractionEnabled = true
        trendingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendingTapped)))
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.videoMaximumDuration = 60
        imagePicker.videoQuality = .typeLow
        imagePicker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUserData()
    }
    
    //MARk:- Actions and Methods
    
    func setUserData(){
        profileImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        userSmallImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        userSmallImage.layer.cornerRadius = userSmallImage.frame.height / 2
        lblUsername.text = Utility.getLoginUserFullName()
        lblUserBio.text  = Utility.getLoginUserBio()
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
        return 10
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.frame = view.frame
        itemView.userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
        itemView.userImage.layer.cornerRadius = 25
        itemView.feedBackView.isUserInteractionEnabled = true
        itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped)))
        itemView.postlikeView.isUserInteractionEnabled = true
        itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped)))
        itemView.feedImage.clipsToBounds = true
        itemView.feedImage.image = UIImage(named: "iFollow-white-logo-1")
        itemView.feedImage.contentMode = .scaleAspectFit
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let image = LightboxImage(image: UIImage(named: "Rectangle 15")!, text: "This is a simple dummy text for viewing image.", videoURL: nil)
        let vc = LightboxController(images: [image], startIndex: 0)
        vc.pageDelegate = self
        vc.dismissalDelegate = self
        vc.dynamicBackground = true
        self.present(vc, animated: true, completion: nil)
        
    }
    
//    func userImageTapped(index: Int) {
//        let vc = Utility.getOtherUserProfileViewController()
//        self.present(vc, animated: true, completion: nil)
//    }
    
    @objc func userImageTapped() {
        let vc = Utility.getOtherUserProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func feedbackViewTapped(){
        let vc = Utility.getCommentViewController()
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func postLikeViewTapped(){
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
