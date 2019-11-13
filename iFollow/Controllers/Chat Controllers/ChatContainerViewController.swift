//
//  ChatContainerViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var onlineIcon: UIImageView!
    @IBOutlet weak var lblOnlineStatus: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    var chatController = UIViewController()
    var isFromGroupChat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMessage.layer.masksToBounds = true
        lblMessage.layer.cornerRadius = 5
        
        lblOnlineStatus.text = isFromGroupChat ? "Watson, Poland, Kane..(+15 others)" : "Online"
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topViewTapped)))
        
        chatController = Utility.getChatViewController()
        add(asChildViewController: chatController)
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
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
