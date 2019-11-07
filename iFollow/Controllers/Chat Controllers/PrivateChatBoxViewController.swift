//
//  PrivateChatBoxViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class PrivateChatBoxViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var lblAll: UILabel!
    @IBOutlet weak var allSelectedView: UIView!
    
    @IBOutlet weak var familyView: UIView!
    @IBOutlet weak var lblFamily: UILabel!
    @IBOutlet weak var familySelectedView: UIView!
    
    @IBOutlet weak var groupsView: UIView!
    @IBOutlet weak var lblGroups: UILabel!
    @IBOutlet weak var groupSelectedView: UIView!
    
    var selectedIndex = 0
    var allChatsController = UIViewController()
    var groupsChatController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allChatsController = Utility.getAllChatsListViewController()
        (allChatsController as! AllChatsListViewController).isPrivateChat = true
        groupsChatController = Utility.getAllGroupsListViewController()
        (groupsChatController as! AllGroupsListViewController).isPrivateChat = true
        
        allView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allTapped)))
        familyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(familyTapped)))
        groupsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupsTapped)))
        changeTab()
    }
   
    //MARK: Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @objc func allTapped(){
        selectedIndex = 0
        changeTab()
    }
    
    @objc func familyTapped(){
        selectedIndex = 1
        changeTab()
    }
    
    @objc func groupsTapped(){
        selectedIndex = 2
        changeTab()
    }
    
    func changeTab(){
        
        if (selectedIndex == 0){
            
            lblAll.textColor = Theme.profileLabelsYellowColor
            allSelectedView.isHidden = false
            
            lblFamily.textColor = Theme.privateChatBoxTabsColor
            familySelectedView.isHidden = true
            lblGroups.textColor = Theme.privateChatBoxTabsColor
            groupSelectedView.isHidden = true
            
            remove(asChildViewController: [groupsChatController])
            add(asChildViewController: allChatsController)
            
        }
        else if (selectedIndex == 1){
            
            lblFamily.textColor = Theme.profileLabelsYellowColor
            familySelectedView.isHidden = false
            
            lblAll.textColor = Theme.privateChatBoxTabsColor
            allSelectedView.isHidden = true
            lblGroups.textColor = Theme.privateChatBoxTabsColor
            groupSelectedView.isHidden = true
            
            remove(asChildViewController: [allChatsController, groupsChatController])
            add(asChildViewController: allChatsController)
            
        }
        else if (selectedIndex == 2){
            
            lblGroups.textColor = Theme.profileLabelsYellowColor
            groupSelectedView.isHidden = false
            
            lblAll.textColor = Theme.privateChatBoxTabsColor
            allSelectedView.isHidden = true
            lblFamily.textColor = Theme.privateChatBoxTabsColor
            familySelectedView.isHidden = true
            
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
