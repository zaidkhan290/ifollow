//
//  SendStoryViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 11/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import Firebase

protocol SendStoryViewControllerDelegate {
    func sendStoryPopupDismissed()
}

class SendStoryViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    
    var recentChatsArray = [RecentChatsModel]()
    
    var currentUserId = 0
    var currentUserName = ""
    var currentStoryId = 0
    var currentStoryMedia = ""
    var currentStoryMediaType = ""
   
    var delegate: SendStoryViewControllerDelegate!
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.roundTopCorners(radius: 30)
        
        //searchView.layer.borderWidth = 1
       // searchView.layer.borderColor = UIColor.black.cgColor
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "Search", color: Theme.searchFieldColor)
        
//        allView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allViewTapped)))
//        groupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupViewTapped)))
        
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        friendsTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        friendsTableView.rowHeight = 60
        
        changeTab()
        getRecentChats()
    }
    
    //MARK:- Actions
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        if (delegate != nil){
            self.delegate.sendStoryPopupDismissed()
        }
    }

    @objc func allViewTapped(){
        selectedIndex = 0
        changeTab()
    }
    
    @objc func groupViewTapped(){
        selectedIndex = 1
        changeTab()
    }
    
    func changeTab(){
        
//        if (selectedIndex == 0){
//            lblAll.textColor = Theme.profileLabelsYellowColor
//            allSelectedView.isHidden = false
//            lblGroup.textColor = Theme.privateChatBoxTabsColor
//            groupSelectedView.isHidden = true
//        }
//        else{
//            lblGroup.textColor = Theme.profileLabelsYellowColor
//            groupSelectedView.isHidden = false
//            lblAll.textColor = Theme.privateChatBoxTabsColor
//            allSelectedView.isHidden = true
//        }
        
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
                        if (recentChatModel.chatUserId != self.currentUserId){
                            self.recentChatsArray.append(recentChatModel)
                        }
                    }
                    Utility.showOrHideLoader(shouldShow: false)
                    self.friendsTableView.reloadData()
                    
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

extension SendStoryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChatsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        let user = recentChatsArray[indexPath.row]
        let sendImage = UIImage(named: "storySend")?.withRenderingMode(.alwaysOriginal)
        
        cell.btnSend.backgroundColor = .white
        cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
        cell.btnSend.isUserInteractionEnabled = false
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.lblUsernameTopConstraint.constant = 22
        cell.lblLastSeen.isHidden = true
        cell.updateConstraintsIfNeeded()
        cell.layoutSubviews()
        
        cell.userImage.sd_setImage(with: URL(string: user.chatUserImage), placeholderImage: UIImage(named: "img_placeholder"))
        cell.lblUsername.text = user.chatUserName
        if (user.isRead){
            cell.btnSend.setTitle("Sent", for: .normal)
            cell.btnSend.setImage(nil, for: .normal)
        }
        else{
            cell.btnSend.setTitle("", for: .normal)
            cell.btnSend.setImage(sendImage, for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (recentChatsArray[indexPath.row].isRead == false){
            recentChatsArray[indexPath.row].isRead = true
            
            let chatRef = rootRef.child("NormalChats").child(recentChatsArray[indexPath.row].chatId)
            chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                       "senderId": "\(Utility.getLoginUserId())",
                                                       "message": currentStoryMedia,
                                                       "type": currentStoryMediaType == "image" ? 2 : 4,
                                                       "isRead": false,
                                                       "timestamp" : ServerValue.timestamp()])
            
            chatRef.childByAutoId().updateChildValues(["senderName": Utility.getLoginUserFullName(),
                                                       "senderId": "\(Utility.getLoginUserId())",
                "message": currentUserId == Utility.getLoginUserId() ? "\(Utility.getLoginUserFullName()) shared story with you." : "\(Utility.getLoginUserFullName()) shared \(currentUserName)'s story with you.",
                                                       "type": 1,
                                                       "isRead": false,
                                                       "timestamp" : ServerValue.timestamp()])
            
        }
        self.friendsTableView.reloadData()
    }
    
}
