//
//  PostCommentViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 30/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class PostCommentViewController: UIViewController {

    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var txtfieldComment: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        commentsView.roundTopCorners(radius: 30)
        commentInputView.layer.cornerRadius = commentInputView.frame.height / 2
        commentsTableView.register(UINib(nibName: "MainCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "MainCommentTableViewCell")
        commentsTableView.register(UINib(nibName: "ReplyCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "ReplyCommentTableViewCell")
        
    }
    
    //MARK:- Methods and Actions
    
    func setupColors(){
        commentsView.setColor()
        commentsTableView.reloadData()
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton){
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
    }

}

extension PostCommentViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1){
            return 3
        }
        else if (section == 4){
            return 5
        }
        else if (section == 9){
            return 4
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCommentTableViewCell", for: indexPath) as! MainCommentTableViewCell
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
            cell.commentView.layer.cornerRadius = 10
            cell.lblUsername.text = indexPath.section % 2 == 0 ? "Sara Alison" : "Emma Watson"
            cell.lblUserComment.text = indexPath.section % 2 == 0 ? "Hey what a nice view... Where is it located? I want to go there ASAP..." : "Wow what a nice view.. I like it too much"
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCommentTableViewCell", for: indexPath) as! ReplyCommentTableViewCell
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
            cell.commentView.layer.cornerRadius = 10
            cell.lblUsername.text = indexPath.row % 2 == 0 ? "Sara Alison" : "Emma Watson"
            cell.lblUserComment.text = indexPath.row % 2 == 0 ? "Yup its too much nice. It is Ratti Gali Lake located in Azad Kashmir Pakistan" : "Yes I also like it... I want to go there everytime"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
