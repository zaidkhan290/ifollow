//
//  AllGroupsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import Firebase

class AllGroupsListViewController: UIViewController {
    
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    var userLastSeen: Double = 0.0
    
    var chatRef = rootRef
    var isPrivateChat = false
    var groupsList = [GroupChatModel]()
    var searchGroupArray = [GroupChatModel]()
    
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
        txtFieldSearch.addTarget(self, action: #selector(searchTextFieldTextChanged), for: .editingChanged)
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
                                if (lastMessageTime > recentChat.userClearChatTime){
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
                                }
                                else{
                                    recentChat.groupLastMessage = "Chat cleared"
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
    
    @objc func searchTextFieldTextChanged(){
        if (txtFieldSearch.text == ""){
            self.searchGroupArray.removeAll()
        }
        else{
            self.searchGroupArray = self.groupsList.filter{$0.groupName.localizedCaseInsensitiveContains(txtFieldSearch.text!)}
        }
        self.chatListTableView.reloadData()
    }
    
    func showClearChatPopup(groupId: String){
        let vc = UIAlertController(title: "Clear Chat", message: "Are you sure you want to clear this group chat?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                self.clearGroupChat(groupId: groupId)
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func clearGroupChat(groupId: String){
        Utility.showOrHideLoader(shouldShow: true)
        var time = Date().timeIntervalSince1970.rounded()
        time = time * 1000
        let params = ["group_id": groupId,
                      "time": time] as [String: Any]

        API.sharedInstance.executeAPI(type: .clearGroupChatMessage, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf("Chat cleared", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in

                    }
                    self.getGroupsList()
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in

                    }
                }
                else if (status == .authError){
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
        return txtFieldSearch.text == "" ? groupsList.count : searchGroupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        let group = txtFieldSearch.text == "" ? groupsList[indexPath.row] : searchGroupArray[indexPath.row]
        
        cell.backgroundColor = isPrivateChat ? .clear : .white
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: group.groupImage)!)
        cell.lblUsername.text = group.groupName
        cell.lblTime.text = group.groupLastMessage == "" ? Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: group.groupCreatedAt)) : Utility.timeAgoSince(Date(timeIntervalSince1970: (group.groupLastMessageTime / 1000)))
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
        vc.chatId = txtFieldSearch.text == "" ? groupsList[indexPath.row].groupChatId : searchGroupArray[indexPath.row].groupChatId
        vc.groupChatModel = txtFieldSearch.text == "" ? groupsList[indexPath.row] : searchGroupArray[indexPath.row]
        self.pushToVC(vc: vc)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Clear Chat") { (action, indexPath) in
            self.showClearChatPopup(groupId: self.groupsList[indexPath.row].groupChatId)
        }
        return [deleteAction]
    }
}
