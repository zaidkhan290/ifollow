//
//  ChatContainerViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Firebase
import Loaf

class ChatContainerViewController: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var onlineIcon: UIImageView!
    @IBOutlet weak var lblOnlineStatus: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblOnlineStatusLeadingConstraint: NSLayoutConstraint!
    var isPrivateChat = false
    
    var chatController = UIViewController()
    var groupChatController = UIViewController()
    var isFromGroupChat = false
    var isFromProfile = false
    var chatId = ""
    var groupChatModel = GroupChatModel()
    var userId = 0
    var userName = ""
    var chatUserImage = ""
    var isUserOnline = false
    
    var isFromPush = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblMessage.layer.masksToBounds = true
        lblMessage.layer.cornerRadius = 5
        onlineIcon.layer.cornerRadius = onlineIcon.frame.height / 2
        
        lblUsername.text = isFromGroupChat ? groupChatModel.groupName : userName
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
       
        if (isFromGroupChat){
            btnBlock.isHidden = true
            if (groupChatModel.groupImage == ""){
                userImage.image = UIImage(named: "Rectangle 108")
            }
            else{
                userImage.sd_setImage(with: URL(string: groupChatModel.groupImage)!)
            }
            lblOnlineStatus.text = groupChatModel.groupUsers.map{$0.userFullName}.joined(separator: ", ")
            lblOnlineStatusLeadingConstraint.constant = 10
            self.view.updateConstraintsIfNeeded()
            self.view.layoutSubviews()
            groupChatController = Utility.getGroupChatViewController()
            (groupChatController as! GroupChatViewController).chatId = self.chatId
            (groupChatController as! GroupChatViewController).groupModel = self.groupChatModel
            add(asChildViewController: groupChatController)
        }
        else{
            btnBlock.isHidden = false
            chatController = Utility.getChatViewController()
            (chatController as! ChatViewController).isPrivateChat = isPrivateChat
            (chatController as! ChatViewController).chatId = self.chatId
            (chatController as! ChatViewController).otherUserId = self.userId
            (chatController as! ChatViewController).userImage = self.chatUserImage
            (chatController as! ChatViewController).userName = self.userName
            add(asChildViewController: chatController)
            userImage.sd_setImage(with: URL(string: chatUserImage), placeholderImage: UIImage(named: "img_placeholder"))
        }
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topViewTapped)))
        
        setupColor()
        
        self.view.updateConstraintsIfNeeded()
        self.view.layoutSubviews()
        
        if (!isFromGroupChat){
            let userRef = rootRef.child("Users").child("\(userId)")
            userRef.observe(.value) { (snapshot) in
                if (snapshot.hasChildren()){
                    let isOnline = snapshot.childSnapshot(forPath: "isActive").value as! Bool
                    self.isUserOnline = isOnline
                    self.changeOnlineStatus()
                }
                
            }
            
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isOnChat": true])
        }
        else{
            onlineIcon.isHidden = true
            //lblOnlineStatus.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let userRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
        userRef.updateChildValues(["lastSeen": ServerValue.timestamp(),
                                   "isOnChat": false])
    }
    
    func setupColor(){
        if (isPrivateChat){
            self.lblMessage.backgroundColor = .clear
            lblUsername.textColor = .white
            self.view.setPrivateChatColor()
            self.alertView.setPrivateChatColor()
            self.alertViewHeightConstraint.constant = 40
            self.lblMessage.isHidden = false
        }
        else{
            self.view.setColor()
            self.alertView.setColor()
            self.alertViewHeightConstraint.constant = 0
            self.lblMessage.isHidden = true
        }
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        
        if (isFromPush){
            let vc = Utility.getTabBarViewController()
            UIWINDOW!.rootViewController = vc
        }
        else{
            if (isFromProfile){
                self.dismiss(animated: true, completion: nil)
            }
            else{
                self.goBack()
            }
        }
        
    }
    
    func changeOnlineStatus(){
        onlineIcon.backgroundColor = UIColor(named: isUserOnline ? "ActiveColor" : "AwayColor")
        lblOnlineStatus.text = isUserOnline ? "Online" : "Away"
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "imageButtonTapped"), object: nil)
    }
    
    @IBAction func btnBlockTapped(_ sender: UIButton){
        showBlockUserPopup()
    }
    
    func showBlockUserPopup(){
        let vc = UIAlertController(title: "Block", message: "Are you sure you want to block \(userName)", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: true)
                let params = ["user_id": self.userId]
                API.sharedInstance.executeAPI(type: .blockUser, method: .post, params: params, completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        Utility.showOrHideLoader(shouldShow: false)
                        if (status == .success){
                            Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                let vc = Utility.getTabBarViewController()
                                UIWINDOW!.rootViewController = vc
                            }
                        }
                        else if (status == .failure){
                            Utility.showOrHideLoader(shouldShow: false)
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                
                            }
                        }
                        else if (status == .authError){
                            Utility.showOrHideLoader(shouldShow: false)
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                Utility.logoutUser()
                            }
                        }
                    }
                })
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func topViewTapped(){
        
        if (isFromGroupChat){
            let vc = Utility.getGroupDetailViewController()
            vc.groupChatId = chatId
            vc.groupModel = self.groupChatModel
            self.pushToVC(vc: vc)
        }
        else{
            let vc = Utility.getOtherUserProfileViewController()
            vc.userId = self.userId
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColor()
    }
}
