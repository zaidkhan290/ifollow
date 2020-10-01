//
//  PostCommentViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 30/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class PostCommentViewController: UIViewController {

    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var txtfieldComment: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var postId = 0
    var commentsArray = [CommentModel]()
    var isForReply = false
    var commentId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        commentsView.roundTopCorners(radius: 30)
        commentInputView.layer.cornerRadius = commentInputView.frame.height / 2
        commentsTableView.register(UINib(nibName: "MainCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "MainCommentTableViewCell")
        commentsTableView.register(UINib(nibName: "ReplyCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "ReplyCommentTableViewCell")
        self.btnSend.isEnabled = false
        txtfieldComment.addTarget(self, action: #selector(txtfieldCommentTextChanged), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if (isForReply){
            
        }
        else{
            getComments()
        }
        
    }
    
    //MARK:- Methods and Actions
    
    func setupColors(){
        commentsView.setColor()
        commentsTableView.reloadData()
    }
    
    @objc func txtfieldCommentTextChanged(){
        btnSend.isEnabled = txtfieldComment.text != ""
    }
    
    func getComments(){
        
        if (commentsArray.count == 0){
            Utility.showOrHideLoader(shouldShow: true)
        }
        
        let params = ["post_id": postId]
                     
        API.sharedInstance.executeAPI(type: .getComments, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.commentsArray.removeAll()
                    let comments = result["data"].arrayValue
                    for comment in comments{
                        let model = CommentModel()
                        model.updateModelWithJSON(json: comment)
                        self.commentsArray.append(model)
                    }
                    self.commentsTableView.reloadData()
                    self.commentsTableView.scrollToRow(at: IndexPath(row: 0, section: self.commentsArray.count - 1), at: .bottom, animated: true)
                    
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
    func postComment(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["post_id": postId,
                      "comment": txtfieldComment.text!]
                     as [String : Any]
        
        API.sharedInstance.executeAPI(type: .postComment, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.txtfieldComment.text = ""
                    self.btnSend.isEnabled = false
                    self.getComments()
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
    func replyComment(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["comment_id": commentId,
                      "comment": txtfieldComment.text!]
                     as [String : Any]
        
        API.sharedInstance.executeAPI(type: .replyComment, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.txtfieldComment.text = ""
                    self.btnSend.isEnabled = false
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton){
        postComment()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
    }

}

extension PostCommentViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (commentsArray[section].commentReplies.count == 0){
            return 1
        }
        else{
            return commentsArray[section].commentReplies.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = commentsArray[indexPath.section]
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCommentTableViewCell", for: indexPath) as! MainCommentTableViewCell
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
            cell.commentView.layer.cornerRadius = 10
            cell.userImageView.sd_setImage(with: URL(string: comment.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
            cell.lblUsername.text = comment.userName
            cell.lblUserComment.text = comment.comment
            cell.lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: comment.commentDate))
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCommentTableViewCell", for: indexPath) as! ReplyCommentTableViewCell
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
            cell.commentView.layer.cornerRadius = 10
            cell.userImageView.sd_setImage(with: URL(string: comment.commentReplies[indexPath.row - 1].userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
            cell.lblUsername.text = comment.commentReplies[indexPath.row - 1].userName
            cell.lblUserComment.text = comment.commentReplies[indexPath.row - 1].comment
            cell.lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: comment.commentReplies[indexPath.row - 1].commentDate))
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
