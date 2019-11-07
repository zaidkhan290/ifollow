//
//  TabBarViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

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
}
