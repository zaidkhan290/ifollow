//
//  TabBarViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import FirebaseStorage

class TabBarViewController: UIViewController {

    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var homeTab: UIView!
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var homeSelectedView: UIView!
    
    @IBOutlet weak var searchTab: UIView!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchSelectedView: UIView!
    
    @IBOutlet weak var cameraTab: UIView!
    
    @IBOutlet weak var notificationTab: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationSelectedView: UIView!
    
    @IBOutlet weak var profileTab: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileSelectedView: UIView!
    
    var selectedIndex = 0
    var storageRef: StorageReference?
    var storyImage = UIImage()
    
    var homeController = UIViewController()
    var exploreController = UIViewController()
    var notificationController = UIViewController()
    var profileController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.dropShadow(color: .white)
       
        homeTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(homeTabTapped)))
        searchTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchTabTapped)))
        cameraTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraTabTapped)))
        notificationTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationTabTapped)))
        profileTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTabTapped)))
        
        homeController = Utility.getHomeViewController()
        exploreController = Utility.getExploreViewController()
        notificationController = Utility.getNotificationViewController()
        profileController = Utility.getProfileViewController()
        
        changeTab()
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutUser), name: NSNotification.Name("logoutUser"), object: nil)
        
    }
    
    //MARK:- Methods
    
    @objc func logoutUser(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func homeTabTapped(){
        selectedIndex = 0
        changeTab()
    }
    
    @objc func searchTabTapped(){
        selectedIndex = 1
        changeTab()
    }
    
    @objc func cameraTabTapped(){
        selectedIndex = 2
        changeTab()
    }
    
    @objc func notificationTabTapped(){
        selectedIndex = 3
        changeTab()
    }
    
    @objc func profileTabTapped(){
        selectedIndex = 4
        changeTab()
    }
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func changeTab(){
        
        if (selectedIndex == 0){
            
            homeImage.image = UIImage(named: "homeSelected")
            homeSelectedView.isHidden = false
            
            searchImage.image = UIImage(named: "search")
            searchSelectedView.isHidden = true
            notificationImage.image = UIImage(named: "notification")
            notificationSelectedView.isHidden = true
            profileImage.image = UIImage(named: "profile")
            profileSelectedView.isHidden = true
            
            remove(asChildViewController: [exploreController, notificationController, profileController])
            add(asChildViewController: homeController)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHomeData"), object: nil)
            
        }
        else if (selectedIndex == 1){
            
            searchImage.image = UIImage(named: "searchSelected")
            searchSelectedView.isHidden = false
            
            homeImage.image = UIImage(named: "home")
            homeSelectedView.isHidden = true
            notificationImage.image = UIImage(named: "notification")
            notificationSelectedView.isHidden = true
            profileImage.image = UIImage(named: "profile")
            profileSelectedView.isHidden = true
            
            remove(asChildViewController: [homeController, notificationController, profileController])
            add(asChildViewController: exploreController)
            
        }
        else if (selectedIndex == 2){
            openCamera()
        }
        else if (selectedIndex == 3){
            
            notificationImage.image = UIImage(named: "notificationSelected")
            notificationSelectedView.isHidden = false
            
            homeImage.image = UIImage(named: "home")
            homeSelectedView.isHidden = true
            searchImage.image = UIImage(named: "search")
            searchSelectedView.isHidden = true
            profileImage.image = UIImage(named: "profile")
            profileSelectedView.isHidden = true
            
            remove(asChildViewController: [homeController, exploreController, profileController])
            add(asChildViewController: notificationController)
            
        }
        else if (selectedIndex == 4){
            
            profileImage.image = UIImage(named: "profileSelected")
            profileSelectedView.isHidden = false
            
            homeImage.image = UIImage(named: "home")
            homeSelectedView.isHidden = true
            searchImage.image = UIImage(named: "search")
            searchSelectedView.isHidden = true
            notificationImage.image = UIImage(named: "notification")
            notificationSelectedView.isHidden = true
            
            remove(asChildViewController: [homeController, exploreController, notificationController])
            add(asChildViewController: profileController)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserPosts"), object: nil)
            
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewControllers: [UIViewController]) {
        
        for viewController in viewControllers{
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        
    }
    
    func saveStoryImageToFirebase(image: UIImage, caption: String){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/StoryImage\(timeStemp).jgp")
        
        //        let imageData2 = UIImagePNGRepresentation(image)
        if let imageData2 = image.jpegData(compressionQuality: 1) {
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = picRef?.putData(imageData2, metadata: metadata, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    picRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
                            self.postStory(mediaUrl: imageURL.absoluteString, postType: "image", caption: caption)
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func saveStoryVideoToFirebase(videoURL: URL, caption: String){
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Videos")
        let videoRef = iosRef?.child("/StoryVideo\(timeStemp).mov")
        
        if let videoData = try? Data(contentsOf: videoURL){
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = videoRef?.putData(videoData, metadata: nil, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    videoRef?.downloadURL(completion: { (url, error) in
                        if let videoURL = url{
                            self.postStory(mediaUrl: videoURL.absoluteString, postType: "video", caption: caption)
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func postStory(mediaUrl: String, postType: String, caption: String){
        let params = ["media": mediaUrl,
                      "expire_hours": Utility.getLoginUserStoryExpireHours(),
                      "caption": caption,
                      "media_type": postType] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .createStory, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
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
}

extension TabBarViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage, caption: String) {
        storyImage = image
        self.saveStoryImageToFirebase(image: storyImage, caption: caption)
    }
    
    func getStoryVideo(videoURL: URL, caption: String) {
        self.saveStoryVideoToFirebase(videoURL: videoURL, caption: caption)
    }
}
