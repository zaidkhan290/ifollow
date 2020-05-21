//
//  ShareStoriesViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 21/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

protocol ShareStoriesViewControllerDelegate: class {
    func shareStoryToMyStoryAndFriends(isToSendMyStory: Bool, friendsArray: [RecentChatsModel])
}

class ShareStoriesViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shareTableView: UITableView!
    var recentChatsArray = [RecentChatsModel]()
    
    var isSendToMyStory = false
    var delegate: ShareStoriesViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.roundTopCorners(radius: 30)
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        shareTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        shareTableView.rowHeight = 60
        shareTableView.tableFooterView = UIView()
        getRecentChats()
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.goBack()
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
        self.delegate.shareStoryToMyStoryAndFriends(isToSendMyStory: self.isSendToMyStory, friendsArray: self.recentChatsArray.filter{$0.isRead == true})
    }
    
    
    func getRecentChats(){
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .getNormalChatsList, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    self.recentChatsArray.removeAll()
                    let chatArray = result["message"].arrayValue
                    for chat in chatArray{
                        let recentChatModel = RecentChatsModel()
                        recentChatModel.updateModelWithJSON(json: chat)
                        if (self.recentChatsArray.filter{$0.chatUserId == recentChatModel.chatUserId}.count == 0){
                            self.recentChatsArray.append(recentChatModel)
                        }
                    }
                    self.getTrenders()
                    
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
    func getTrenders(){
        API.sharedInstance.executeAPI(type: .getTrendersAndTrendings, method: .get, params: ["id": Utility.getLoginUserId()]) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    let chatArray = result["trendings"].arrayValue
                    for chat in chatArray{
                        let recentChatModel = RecentChatsModel()
                        recentChatModel.chatUserId = chat["user_id"].intValue
                        recentChatModel.chatUserName = chat["name"].stringValue
                        recentChatModel.chatUserImage = chat["user_image"].stringValue.replacingOccurrences(of: "\\", with: "")
                        if (self.recentChatsArray.filter{$0.chatUserId == recentChatModel.chatUserId}.count == 0) && (self.recentChatsArray.filter{$0.chatUserId == recentChatModel.chatUserId}.count == 0){
                            
                            self.recentChatsArray.append(recentChatModel)
                        }
                    }
                    Utility.showOrHideLoader(shouldShow: false)
                    self.shareTableView.reloadData()
                    
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
}

extension ShareStoriesViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        }
        else{
            return recentChatsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell

        cell.btnSend.isHidden = true
        cell.lblLastSeen.isHidden = true
        cell.lblUsernameTopConstraint.constant = 22
        cell.selectImage.isHidden = false
        cell.selectImage.isUserInteractionEnabled = false
        cell.updateConstraintsIfNeeded()
        cell.layoutSubviews()
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        
        if (indexPath.section == 0){
            cell.userImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "img_placeholder"))
            cell.lblUsername.text = "My Story"
            cell.selectImage.image = UIImage(named: isSendToMyStory ? "select" : "unselect")
            cell.backgroundColor = isSendToMyStory ? UIColor.lightGray.withAlphaComponent(0.2) : UIColor.white
        }
        else{
            let user = recentChatsArray[indexPath.row]
            cell.userImage.sd_setImage(with: URL(string: user.chatUserImage), placeholderImage: UIImage(named: "img_placeholder"))
            cell.lblUsername.text = user.chatUserName
            if (user.isRead){
                cell.selectImage.image = UIImage(named: "select")
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            }
            else{
                cell.selectImage.image = UIImage(named: "unselect")
                cell.backgroundColor = .white
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0){
            isSendToMyStory = !isSendToMyStory
        }
        else{
            recentChatsArray[indexPath.row].isRead = !recentChatsArray[indexPath.row].isRead
        }
        self.shareTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 0
        }
        else{
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return ""
        }
        else{
            return "Recent Chats"
        }
    }
    
}
