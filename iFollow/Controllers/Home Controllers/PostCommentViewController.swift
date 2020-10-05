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

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var txtfieldComment: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var postId = 0
    var postUserId = 0
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
        self.btnBack.setImage(UIImage(named: isForReply ? "back" : "select_down"), for: .normal)
        txtfieldComment.addTarget(self, action: #selector(txtfieldCommentTextChanged), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if (isForReply){
            self.commentsTableView.reloadData()
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
                    
                    if (self.isForReply){
                        self.commentsArray = self.commentsArray.filter{$0.commentId == self.commentId}
                    }
                    self.commentsTableView.reloadData()
                    if (self.commentsArray.count > 0){
                        self.commentsTableView.scrollToRow(at: IndexPath(row: 0, section: self.commentsArray.count - 1), at: .bottom, animated: true)
                    }
                    
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
                      "comment": txtfieldComment.text!,
                      "user_id": postUserId]
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
                      "comment": txtfieldComment.text!,
                      "user_id": commentsArray.first!.userId]
                     as [String : Any]
        
        API.sharedInstance.executeAPI(type: .replyComment, method: .post, params: params) { (status, result, message) in
            
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
    
    func showDeleteCommentPopup(indexPath: IndexPath){
        
        let alert = UIAlertController(title: "Delete Comment", message: "Are you sure you want to delete this comment?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                self.deleteComment(indexPath: indexPath)
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteComment(indexPath: IndexPath){
        var params = [String : Int]()
        var endPoint: EndPoint!
        
        if (indexPath.row == 0){
            endPoint = .deleteComment
            params = ["comment_id": commentsArray[indexPath.section].commentId]
        }
        else{
            endPoint = .deleteReply
            params = ["reply_id": commentsArray[indexPath.section].commentReplies[indexPath.row - 1].commentId]
        }
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: endPoint, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
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
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        if (isForReply){
            self.goBack()
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton){
        if (isForReply){
            replyComment()
        }
        else{
            postComment()
        }
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
            cell.delegate = self
            cell.indexPath = indexPath
            cell.btnReply.isHidden = isForReply
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row > 0 && !isForReply){
            let comment = commentsArray[indexPath.section]
            let vc = Utility.getPostCommentController()
            vc.isForReply = true
            vc.postId = postId
            vc.postUserId = postUserId
            vc.commentId = comment.commentId
            vc.commentsArray = [comment]
            self.pushToVC(vc: vc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (postUserId == Utility.getLoginUserId()){
            return true
        }
        else if (indexPath.row == 0 && commentsArray[indexPath.section].userId == Utility.getLoginUserId()){
            return true
        }
        else if (indexPath.row > 0 && commentsArray[indexPath.section].commentReplies[indexPath.row - 1].userId == Utility.getLoginUserId()){
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, bool) in
            DispatchQueue.main.async {
                self.showDeleteCommentPopup(indexPath: indexPath)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            DispatchQueue.main.async {
//                self.deleteComment(indexPath: indexPath)
//            }
//        }
//        return[deleteAction]
//
//    }
}

extension PostCommentViewController: MainCommentTableViewCellDelegate{
    func replyComment(indexPath: IndexPath) {
        let comment = commentsArray[indexPath.section]
        let vc = Utility.getPostCommentController()
        vc.isForReply = true
        vc.postUserId = postUserId
        vc.postId = postId
        vc.commentId = comment.commentId
        vc.commentsArray = [comment]
        self.pushToVC(vc: vc)
    }
}
