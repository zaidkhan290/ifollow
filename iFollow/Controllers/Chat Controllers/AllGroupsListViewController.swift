//
//  AllGroupsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class AllGroupsListViewController: UIViewController {
    
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    var userLastSeen: Double = 0.0
    
    var chatRef = rootRef
    var isPrivateChat = false
    var groupsList = [GroupChatModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (isPrivateChat){
            searchView.dropShadow(color: Theme.privateChatBoxSearchBarColor)
            searchView.layer.cornerRadius = 25
            Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: .white)
            self.view.backgroundColor = .clear
            lblAlert.text = "Messages will be deleted if not read in 12 hours"
        }
        else{
            searchView.dropShadow(color: .white)
            searchView.layer.cornerRadius = 25
            Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: Theme.searchFieldColor)
            lblAlert.text = ""
        }
        
        chatRef = chatRef.child("GroupChats")
        let cellNib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        chatListTableView.register(cellNib, forCellReuseIdentifier: "ChatListCell")
        chatListTableView.rowHeight = 80
        getGroupsList()
        NotificationCenter.default.addObserver(self, selector: #selector(getGroupsList), name: NSNotification.Name(rawValue: "RefreshGroupsList"), object: nil)
    }
    
    @objc func getGroupsList(){
        if (groupsList.count == 0){
            Utility.showOrHideLoader(shouldShow: true)
        }
        
        API.sharedInstance.executeAPI(type: .getAllGroups, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    self.view.isUserInteractionEnabled = false
                    self.groupsList.removeAll()
                    let groupArray = result["chat_room_list"].arrayValue
                    for group in groupArray{
                        let model = GroupChatModel()
                        model.updateModelWithJSON(json: group)
                        self.groupsList.append(model)
                    }
                    self.chatRef.removeAllObservers()
                    self.chatRef.observe(.childAdded) { (chatSnapshot) in
                        if let recentChat = self.groupsList.first(where: {$0.groupChatId == chatSnapshot.key}){
                            let chatNode = self.chatRef.child(chatSnapshot.key)
                            chatNode.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                                
                                let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                                let userName = (snapshot.childSnapshot(forPath: "senderName").value as! String)
                                let type = (snapshot.childSnapshot(forPath: "type").value as! Int)
                                let message = (snapshot.childSnapshot(forPath: "message").value as! String)
                                let lastMessageTime = (snapshot.childSnapshot(forPath: "timestamp").value as! Double)
                               // let lastMessageIsRead = (snapshot.childSnapshot(forPath: "isRead").value as! Bool)
                                
                                    recentChat.groupLastMessageTime = lastMessageTime
//                                    if (userId == "\(Utility.getLoginUserId())"){
//                                        recentChat.isRead = true
//                                    }
//                                    else{
//                                        recentChat.isRead = lastMessageIsRead
//                                    }
                                
                                    if (type == 1){
                                        recentChat.groupLastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: \(message)" : "\(userName): \(message)")
                                    }
                                    else if (type == 2){
                                        recentChat.groupLastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Image" : "\(userName): Image")
                                    }
                                    else if (type == 3){
                                        recentChat.groupLastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Audio" : "\(userName): Audio")
                                    }
                                    else if (type == 4){
                                        recentChat.groupLastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Video" : "\(userName): Video")
                                    }
                                
                                
                                Utility.showOrHideLoader(shouldShow: false)
                                self.groupsList.sort(by: { (model1, model2) -> Bool in
                                    return model1.groupLastMessageTime > model2.groupLastMessageTime
                                })
                                self.view.isUserInteractionEnabled = true
                                self.chatListTableView.reloadData()
                            })
                        }
                        
                    }
                    self.view.isUserInteractionEnabled = true
                    Utility.showOrHideLoader(shouldShow: false)
                    
                }
                else if (status == .failure){
                    self.view.isUserInteractionEnabled = true
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    self.view.isUserInteractionEnabled = true
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
}

extension AllGroupsListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        let group = groupsList[indexPath.row]
        
        cell.backgroundColor = isPrivateChat ? .clear : .white
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: group.groupImage)!)
        cell.lblUsername.text = group.groupName
        cell.lblTime.text = group.groupLastMessage == "" ? Utility.getNotificationTime(date: Utility.getNotificationDateFrom(dateString: group.groupCreatedAt)) : Utility.getNotificationTime(date: Date(timeIntervalSince1970: (group.groupLastMessageTime / 1000)))
        if (group.groupAdminId == Utility.getLoginUserId()){
            cell.lblUserMessage.text = group.groupLastMessage == "" ? "You created" : group.groupLastMessage
        }
        else{
            cell.lblUserMessage.text = group.groupLastMessage == "" ? "You were added" : group.groupLastMessage
        }
        cell.lblMessageCounter.isHidden = true
        cell.messageCounterIcon.isHidden = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Utility.getChatContainerViewController()
        vc.isFromGroupChat = true
        vc.isPrivateChat = isPrivateChat
        vc.chatId = groupsList[indexPath.row].groupChatId
        vc.groupChatModel = groupsList[indexPath.row]
        self.pushToVC(vc: vc)
    }
    
}
