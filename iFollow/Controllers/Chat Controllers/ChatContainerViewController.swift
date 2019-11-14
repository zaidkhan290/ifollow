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
    var isPrivateChat = false
    
    var chatController = UIViewController()
    var isFromGroupChat = false
    var isFromProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMessage.layer.masksToBounds = true
        lblMessage.layer.cornerRadius = 5
        
        lblOnlineStatus.text = isFromGroupChat ? "Watson, Poland, Kane..(+15 others)" : "Online"
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topViewTapped)))
        
        chatController = Utility.getChatViewController()
        (chatController as! ChatViewController).isPrivateChat = isPrivateChat
        add(asChildViewController: chatController)
        
        if (isPrivateChat){
            self.lblMessage.backgroundColor = .clear
            lblUsername.textColor = .white
            self.view.backgroundColor = Theme.privateChatBackgroundColor
            self.alertView.backgroundColor = Theme.privateChatBackgroundColor
            
        }
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
