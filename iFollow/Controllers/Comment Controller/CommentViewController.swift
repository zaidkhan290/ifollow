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
    
    var chatRef = rootRef
    
    var chatId = ""
    var postId = 0
    var postUserId = 0
    var postUserImage = ""
    var postUserName = ""
    var postUserLocation = ""
    var postUserMedia = ""
    var postType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commetView.layer.cornerRadius = 20
        commetView.dropShadow(color: .white)
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
        feedImage.contentMode = .scaleAspectFill
        feedImage.clipsToBounds = true
        commentFeedView.layer.cornerRadius = 10
        commentFeedView.dropShadow(color: .white)
        Utility.setTextFieldPlaceholder(textField: txtFieldComment, placeholder: "Type a comment", color: Theme.searchFieldColor)
        
        let swipeDonwGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDonwGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeDonwGestureRecognizer)
        
        userImage.sd_setImage(with: URL(string: postUserImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        lblUsername.text = postUserName
        lblUserLocation.text = postUserLocation
        if (postType == "image"){
            feedImage.sd_setImage(with: URL(string: postUserMedia), placeholderImage: UIImage(named: "photo_placeholder"))
        }
        else{
            feedImage.image = UIImage(named: "post_video")
        }
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
                            
                            self.chatRef = self.chatRef.child("NormalChats").child(self.chatId)
                            
                            let timeStamp = ServerValue.timestamp()
                            
                            self.chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                       "senderId": "\(Utility.getLoginUserId())",
                                                                       "message": self.postUserMedia,
                                                                       "type": self.postType == "image" ? 2 : 4,
                                                                       "isRead": false,
                                                                       "postId": self.postId,
                                                                       "timestamp" : timeStamp])
                            
                            self.chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                                            "senderId": "\(Utility.getLoginUserId())",
                                                                            "message": "\(Utility.getLoginUserFullName()) left feedback on your post: \(self.txtFieldComment.text!)",
                                                                            "type": 1,
                                                                            "isRead": false,
                                                                            "postId": self.postId,
                                                                            "timestamp" : timeStamp])
                            
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
    
    @objc func swipeDownGesture(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
