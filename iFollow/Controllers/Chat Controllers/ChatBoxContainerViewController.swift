//
//  ChatBoxContainerViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import CarbonKit

class ChatBoxContainerViewController: UIViewController {
    
    @IBOutlet weak var privateIcon: UIImageView!
    @IBOutlet weak var chatListView: UIView!
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var allSelectedView: UIView!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var groupSelectedView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnAddGroup: UIButton!
    
    var selectedIndex = 0
    var allChatsController = UIViewController()
    var groupsChatController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListView.roundTopCorners(radius: 30)
        
        allChatsController = Utility.getAllChatsListViewController()
        groupsChatController = Utility.getAllGroupsListViewController()
        
        allView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allTapped)))
        groupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupsTapped)))
        privateIcon.isUserInteractionEnabled = true
        privateIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privateIconTapped)))
        
        changeTab()
        
        
//        let items = ["All", "Groups"]
//        let carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
//        carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: containerView)
//        carbonTabSwipeNavigation.setIndicatorColor(.black)
//        carbonTabSwipeNavigation.setNormalColor(.clear)
//        carbonTabSwipeNavigation.carbonSegmentedControl?.tintColor = .clear
       // carbonTabSwipeNavigation.setSelectedColor(.clear)
        //carbonTabSwipeNavigation.color
        
    }
  
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnAddGroupTapped(_ sender: UIButton) {
        let vc = Utility.getCreateGroupViewController()
        self.pushToVC(vc: vc)
    }
    
    @objc func privateIconTapped(){
        let vc = Utility.getPrivateChatBoxViewControllers()
        self.pushToVC(vc: vc)
    }

    @objc func allTapped(){
        selectedIndex = 0
        changeTab()
    }
    
    @objc func groupsTapped(){
        selectedIndex = 1
        changeTab()
    }
    
    func changeTab(){
        if (selectedIndex == 0){
            allSelectedView.isHidden = false
            groupSelectedView.isHidden = true
            btnAddGroup.isHidden = true
            remove(asChildViewController: [groupsChatController])
            add(asChildViewController: allChatsController)
        }
        else{
            allSelectedView.isHidden = true
            groupSelectedView.isHidden = false
            btnAddGroup.isHidden = false
            remove(asChildViewController: [allChatsController])
            add(asChildViewController: groupsChatController)
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

//extension ChatBoxContainerViewController: CarbonTabSwipeNavigationDelegate{
//    
//    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
//        
//        if (index == 0){
//            return Utility.getAllChatsListViewController()
//        }
//        return Utility.getAllGroupsListViewController()
//        
//    }
//    
//}
