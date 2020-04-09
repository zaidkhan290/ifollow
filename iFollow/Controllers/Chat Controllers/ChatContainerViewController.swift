//
//  ChatContainerViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var onlineIcon: UIImageView!
    @IBOutlet weak var lblOnlineStatus: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    var isPrivateChat = false
    
    var chatController = UIViewController()
    var isFromGroupChat = false
    var isFromProfile = false
    var chatId = ""
    var userId = 0
    var userName = ""
    var chatUserImage = ""
    var isUserOnline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        lblMessage.layer.masksToBounds = true
        lblMessage.layer.cornerRadius = 5
        onlineIcon.layer.cornerRadius = onlineIcon.frame.height / 2
        
        lblUsername.text = isFromGroupChat ? "Family Group" : userName
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
       
        if (isFromGroupChat){
            userImage.image = UIImage(named: "family")
        }
        else{
            userImage.sd_setImage(with: URL(string: chatUserImage), placeholderImage: UIImage(named: "img_placeholder"))
        }
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topViewTapped)))
        
        chatController = Utility.getChatViewController()
        (chatController as! ChatViewController).isPrivateChat = isPrivateChat
        (chatController as! ChatViewController).chatId = self.chatId
        (chatController as! ChatViewController).otherUserId = self.userId
        (chatController as! ChatViewController).userImage = self.chatUserImage
        (chatController as! ChatViewController).userName = self.userName
        add(asChildViewController: chatController)
        
        if (isPrivateChat){
            self.lblMessage.backgroundColor = .clear
            lblUsername.textColor = .white
            self.view.backgroundColor = Theme.privateChatBackgroundColor
            self.alertView.backgroundColor = Theme.privateChatBackgroundColor
            self.alertViewHeightConstraint.constant = 40
            self.lblMessage.isHidden = false
        }
        else{
            self.alertViewHeightConstraint.constant = 0
            self.lblMessage.isHidden = true
        }
        self.view.updateConstraintsIfNeeded()
        self.view.layoutSubviews()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let userRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
        userRef.updateChildValues(["isOnChat": false])
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        if (isFromProfile){
            self.dismiss(animated: true, completion: nil)
        }
        else{
           self.goBack()
        }
        
    }
    
    func changeOnlineStatus(){
        onlineIcon.backgroundColor = UIColor(named: isUserOnline ? "ActiveColor" : "AwayColor")
        lblOnlineStatus.text = isUserOnline ? "Online" : "Away"
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "imageButtonTapped"), object: nil)
    }
    
    @objc func topViewTapped(){
        
        if (isFromGroupChat){
            let vc = Utility.getGroupDetailViewController()
            self.pushToVC(vc: vc)
        }
        else{
            let vc = Utility.getOtherUserProfileViewController()
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
    
}
