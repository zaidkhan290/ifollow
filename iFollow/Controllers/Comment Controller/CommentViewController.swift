//
//  CommentViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 15/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Firebase
import Loaf

class CommentViewController: UIViewController {

    @IBOutlet weak var commetView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserLocation: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var commentFeedView: UIView!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    var chatId = ""
    var postId = 0
    var postUserId = 0
    var postUserImage = ""
    var postUserName = ""
    var postUserLocation = ""
    var postUserMedia = ""
    var postType = ""
    var postCaption = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCommentBoxColor()
        commetView.layer.cornerRadius = 20
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
        feedImage.contentMode = .scaleAspectFill
        feedImage.clipsToBounds = true
        commentFeedView.layer.cornerRadius = 10
        Utility.setTextFieldPlaceholder(textField: txtFieldComment, placeholder: "Type a Feedback", color: Theme.searchFieldColor)
        
        let swipeDonwGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDonwGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeDonwGestureRecognizer)
        
        userImage.sd_setImage(with: URL(string: postUserImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        lblUsername.text = postUserName
        lblUserLocation.text = postUserLocation
        if (postType == "image"){
            feedImage.sd_setImage(with: URL(string: postUserMedia), placeholderImage: UIImage(named: "photo_placeholder"))
            lblStatus.isHidden = true
            feedImage.isHidden = false
        }
        else if (postType == "video"){
            feedImage.image = UIImage(named: "post_video")
            lblStatus.isHidden = true
            feedImage.isHidden = false
        }
        else{
            lblStatus.isHidden = false
            feedImage.isHidden = true
            lblStatus.text = postCaption
        }
    }
    
    func setCommentBoxColor(){
        self.commetView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white
        commetView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
        commentFeedView.dropShadow(color: traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white)
    }
    
    //MARK:- Actions
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        if (txtFieldComment.text == ""){
            Loaf("Please enter your comment", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                
            }
        }
        else{
            
            Utility.showOrHideLoader(shouldShow: true)
            let params = ["user_id": postUserId,
                          "is_private": 0]
            
            API.sharedInstance.executeAPI(type: .createChatRoom, method: .post, params: params) { (status, result, message) in
                
                DispatchQueue.main.async {
                    Utility.showOrHideLoader(shouldShow: false)
                    
                    if (status == .success){
                        self.chatId = result["chat_room_id"].stringValue
                        if (self.chatId != ""){
                            
                            let chatRef = rootRef.child("NormalChats").child(self.chatId)
                            
                            let timeStamp = ServerValue.timestamp()
                            
                            if (self.postType == "image"){
                                chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                           "senderId": "\(Utility.getLoginUserId())",
                                                                           "message": self.postUserMedia,
                                                                           "type": 2,
                                                                           "isRead": false,
                                                                           "postId": self.postId,
                                                                           "timestamp" : timeStamp])
                            }
                            else if (self.postType == "video"){
                                chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                           "senderId": "\(Utility.getLoginUserId())",
                                                                           "message": self.postUserMedia,
                                                                           "type": 4,
                                                                           "isRead": false,
                                                                           "postId": self.postId,
                                                                           "timestamp" : timeStamp])
                            }
                            else{
                                chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                           "senderId": "\(Utility.getLoginUserId())",
                                                                           "message": self.postCaption,
                                                                           "type": 1,
                                                                           "isRead": false,
                                                                           "postId": self.postId,
                                                                           "timestamp" : timeStamp])
                            }
                            
                            chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                            "senderId": "\(Utility.getLoginUserId())",
                                                                            "message": "\(Utility.getLoginUserFullName()) left feedback on your post: \(self.txtFieldComment.text!)",
                                                                            "type": 1,
                                                                            "isRead": false,
                                                                            "postId": self.postId,
                                                                            "timestamp" : timeStamp])
                            self.sendPushNotification()
                            
                            Loaf("Feedback sent", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                        else{
                            Loaf("Failed to add comment", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                            }
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
                
            }
            
        }
        
    }
    
    func sendPushNotification(){
        let params = ["user_id": postUserId,
                      "alert": "\(Utility.getLoginUserFullName()) left feedback on your post",
            "name": Utility.getLoginUserFullName(),
            "data": "\(Utility.getLoginUserFullName()) left feedback on your post",
            "tag": 12,
            "chat_room_id": self.chatId] as [String: Any]
        API.sharedInstance.executeAPI(type: .sendPushNotification, method: .post, params: params) { (status, result, message) in
            
        }
    }
    
    @objc func swipeDownGesture(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setCommentBoxColor()
    }
}
