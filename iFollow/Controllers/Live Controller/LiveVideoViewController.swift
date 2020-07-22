//
//  LiveVideoViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 21/07/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class LiveVideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var commentBoxView: UIView!
    @IBOutlet weak var txtViewComment: UITextView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentsTableView.register(UINib(nibName: "LiveVideoCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveVideoCommentsTableViewCell")
        txtViewComment.layer.cornerRadius = txtViewComment.frame.height / 2
        txtViewComment.clipsToBounds = true
        txtViewComment.layer.borderWidth = 1
        txtViewComment.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtViewComment.text = "Comment"
        txtViewComment.textColor = UIColor.white.withAlphaComponent(0.5)
        txtViewComment.contentInset = UIEdgeInsets(top: 3, left: 10, bottom: 0, right: 5)
        txtViewComment.delegate = self
        txtViewComment.returnKeyType = .send
    }

}

extension LiveVideoViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveVideoCommentsTableViewCell", for: indexPath) as! LiveVideoCommentsTableViewCell
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
        cell.userImageView.clipsToBounds = true
        cell.lblComment.text = indexPath.row % 2 == 0 ? "Wow!! Lets meet bro" : "Woowwwwwwwwwww So nice to see you here 😍😍😍😍😍"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension LiveVideoViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Comment"){
            textView.text = ""
        }
        textView.textColor = .white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == ""){
            textView.text = "Comment"
            textView.textColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
}
