//
//  ChatContainerViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var onlineIcon: UIImageView!
    @IBOutlet weak var lblOnlineStatus: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    var chatController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMessage.layer.masksToBounds = true
        lblMessage.layer.cornerRadius = 5
        
        chatController = Utility.getChatViewController()
        add(asChildViewController: chatController)
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
}
