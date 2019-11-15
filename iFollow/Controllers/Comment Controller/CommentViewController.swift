//
//  CommentViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 15/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet weak var commetView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserLocation: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var commentFeedView: UIView!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commetView.layer.cornerRadius = 20
        commetView.dropShadow(color: .white)
        userImage.layer.cornerRadius = 25
        commentFeedView.layer.cornerRadius = 10
        commentFeedView.dropShadow(color: .white)
        Utility.setTextFieldPlaceholder(textField: txtFieldComment, placeholder: "Type a comment", color: Theme.searchFieldColor)
        
        let swipeDonwGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDonwGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeDonwGestureRecognizer)
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func swipeDownGesture(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
