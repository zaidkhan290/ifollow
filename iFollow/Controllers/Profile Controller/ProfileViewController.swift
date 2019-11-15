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

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var lblTrends: UILabel!
    @IBOutlet weak var lblPosts: UILabel!
    @IBOutlet weak var privateTalkView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFiledSearch: UITextField!
    @IBOutlet weak var carouselView: iCarousel!
    
    var imagePicker = UIImagePickerController()
    
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
        
        lblTrends.isUserInteractionEnabled = true
        lblTrends.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        lblTrending.isUserInteractionEnabled = true
        lblTrending.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image" /*"public.movie"*/]
        imagePicker.delegate = self
        
    }
    
    //MARk:- Actions
    
    @objc func privateChatTapped(){
        let vc = Utility.getChatBoxContainerViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationBar.isHidden = true
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func trendesTapped(){
        let vc = Utility.getTrendersContainerViewController()
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
        itemView.feedImage.clipsToBounds = true
        itemView.feedImage.image = UIImage(named: "iFollow-white-logo-1")
        itemView.feedImage.contentMode = .scaleAspectFit
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
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
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    } 
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension ProfileViewController: PostViewControllerDelegate{
    
    func postTapped(postView: UIViewController) {
        self.view.makeToast("Your post share successfully..")
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
            vc.delegate = self
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
