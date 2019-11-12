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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMessage.layer.masksToBounds = true
        lblMessage.layer.cornerRadius = 5
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    
}
