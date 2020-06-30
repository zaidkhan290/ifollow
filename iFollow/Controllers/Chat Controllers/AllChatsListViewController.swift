//
//  AllChatsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import Firebase

class AllChatsListViewController: UIViewController {

    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    
    var chatRef = rootRef
    var usersRef = rootRef
    var allChatsArray = [RecentChatsModel]()
    var chatsArray = [RecentChatsModel]()
    var searchChatsArray = [RecentChatsModel]()
    var isPrivateChat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (isPrivateChat){
            chatRef = chatRef.child("PrivateChats")
            lblAlert.text = "Messages will be deleted in 12 hours"
            searchView.dropShadow(color: Theme.privateChatBoxSearchBarColor)
            searchView.layer.cornerRadius = 25
            Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: .white)
            self.view.backgroundColor = .clear
        }
        else{
            chatRef = chatRef.child("NormalChats")
            lblAlert.text = ""
            searchView.dropShadow(color: .white)
            searchView.layer.cornerRadius = 25
            Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: Theme.searchFieldColor)
        }
        
        usersRef = usersRef.child("Users")
        let cellNib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        chatListTableView.register(cellNib, forCellReuseIdentifier: "ChatListCell")
        chatListTableView.rowHeight = 80
        txtFieldSearch.addTarget(self, action: #selector(searchTextFieldTextChanged), for: .editingChanged)
        getChatList()
        
    }
    
    func getChatList(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: isPrivateChat ? .getPrivateChatsList : .getNormalChatsList, method: .get, params: nil) { (status, result, message) in
            
            
            DispatchQueue.main.async {
                if (status == .success){
                    self.allChatsArray.removeAll()
                    let chatArray = result["message"].arrayValue
                    for chat in chatArray{
                        let recentChatModel = RecentChatsModel()
                        recentChatModel.updateModelWithJSON(json: chat)
                        self.allChatsArray.append(recentChatModel)
                    }
                    
                    self.chatRef.observe(.childAdded) { (chatSnapshot) in
                        if let recentChat = self.allChatsArray.first(where: {$0.chatId == chatSnapshot.key}){
                            let chatNode = self.chatRef.child(chatSnapshot.key)
                            chatNode.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                                
                                let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                                let type = (snapshot.childSnapshot(forPath: "type").value as! Int)
                                let message = (snapshot.childSnapshot(forPath: "message").value as! String)
                                let lastMessageTime = (snapshot.childSnapshot(forPath: "timestamp").value as! Double)
                                let lastMessageIsRead = (snapshot.childSnapshot(forPath: "isRead").value as! Bool)
                                
                                if (self.isPrivateChat){
                                    
                                    let expireTime = snapshot.childSnapshot(forPath: "expireTime").value as! Double
                                    
                                    let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
                                    
                                    if (Int64(expireTime) > currentTime){
                                        recentChat.lastMessageTime = lastMessageTime
                                        if (userId == "\(Utility.getLoginUserId())"){
                                            recentChat.isRead = true
                                        }
                                        else{
                                            recentChat.isRead = lastMessageIsRead
                                        }
                                        
                                        if (type == 1){
                                            recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: \(message)" : message)
                                        }
                                        else if (type == 2){
                                            recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Image" : "Image")
                                        }
                                        else if (type == 3){
                                            recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Audio" : "Audio")
                                        }
                                        else if (type == 4){
                                            recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Video" : "Video")
                                        }
                                    }
                                    else{
                                        recentChat.lastMessageTime = lastMessageTime
                                        recentChat.isRead = true
                                        recentChat.lastMessage = "  "
                                    }
                                }
                                else{
                                    recentChat.lastMessageTime = lastMessageTime
                                    if (userId == "\(Utility.getLoginUserId())"){
                                        recentChat.isRead = true
                                    }
                                    else{
                                        recentChat.isRead = lastMessageIsRead
                                    }
                                    
                                    if (type == 1){
                                        recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: \(message)" : message)
                                    }
                                    else if (type == 2){
                                        recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Image" : "Image")
                                    }
                                    else if (type == 3){
                                        recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Audio" : "Audio")
                                    }
                                    else if (type == 4){
                                        recentChat.lastMessage = (userId == "\(Utility.getLoginUserId())" ? "You: Video" : "Video")
                                    }
                                }
                               
                                Utility.showOrHideLoader(shouldShow: false)
                                self.chatsArray = self.allChatsArray.filter({$0.lastMessage != ""})
                                self.chatsArray.sort(by: { (model1, model2) -> Bool in
                                    return model1.lastMessageTime > model2.lastMessageTime
                                })
                                self.chatListTableView.reloadData()
                                self.getOnlineStatus()
                            })
                        }
                        
                    }
                    
                    Utility.showOrHideLoader(shouldShow: false)
                    
                    
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
    
    func getOnlineStatus(){
        for chat in chatsArray{
            let chatUserRef = usersRef.child("\(chat.chatUserId)")
            chatUserRef.observe(.value) { (snapshot) in
                if let chatUser = self.chatsArray.first(where: {$0.chatUserId == Int(snapshot.key)}){
                    if snapshot.hasChild("isActive"){
                        let isOnline = snapshot.childSnapshot(forPath: "isActive").value as! Bool
                        chatUser.isUserOnline = isOnline
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func searchTextFieldTextChanged(){
        if (txtFieldSearch.text == ""){
            self.searchChatsArray.removeAll()
        }
        else{
            self.searchChatsArray = self.chatsArray.filter{$0.chatUserName.localizedCaseInsensitiveContains(txtFieldSearch.text!)}
        }
        self.chatListTableView.reloadData()
    }
    
    func showDeleteChatPopup(indexPath: IndexPath){
        let vc = UIAlertController(title: "Delete Chat", message: "Are you sure you want to delete this chat?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                
                if (self.txtFieldSearch.text == ""){
                    self.chatRef.child(self.chatsArray[indexPath.row].chatId).removeValue()
                    self.chatsArray.remove(at: indexPath.row)
                }
                else{
                    self.chatRef.child(self.searchChatsArray[indexPath.row].chatId).removeValue()
                    self.chatsArray.removeAll{$0.chatId == self.searchChatsArray[indexPath.row].chatId}
                    self.searchChatsArray.remove(at: indexPath.row)
                }
                Loaf("Chat deleted", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1)) { (handler) in
                    
                }
                self.chatListTableView.deleteRows(at: [indexPath], with: .left)
                self.chatListTableView.reloadData()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }

}

extension AllChatsListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtFieldSearch.text == "" ? chatsArray.count : searchChatsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        cell.backgroundColor = isPrivateChat ? .clear : .white
        cell.lblUsername.font = Theme.getLatoBoldFontOfSize(size: 18)
        
        let chat = txtFieldSearch.text == "" ? chatsArray[indexPath.row] : searchChatsArray[indexPath.row]
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: chat.chatUserImage), placeholderImage: UIImage(named: "img_placeholder"))
        cell.lblUsername.text = chat.chatUserName
        cell.lblUserMessage.text = chat.lastMessage
        cell.lblMessageCounter.isHidden = true
        cell.messageCounterIcon.isHidden = chat.isRead
        let lastMessageDate = Date(timeIntervalSince1970: (chat.lastMessageTime / 1000))
        cell.lblTime.text = Utility.timeAgoSince(lastMessageDate)
        cell.lblUserMessage.font = chat.isRead ? Theme.getLatoRegularFontOfSize(size: 13) : Theme.getLatoBoldFontOfSize(size: 13)
        cell.onlineIcon.isHidden = !chat.isUserOnline
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Utility.getChatContainerViewController()
        let chat = txtFieldSearch.text == "" ? chatsArray[indexPath.row] : searchChatsArray[indexPath.row]
        chat.isRead = true
        vc.isFromGroupChat = false
        vc.isPrivateChat = isPrivateChat
        vc.chatId = chat.chatId
        vc.userId = chat.chatUserId
        vc.userName = chat.chatUserName
        vc.chatUserImage = chat.chatUserImage
        self.chatListTableView.reloadData()
        self.pushToVC(vc: vc)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.showDeleteChatPopup(indexPath: indexPath)
        }
        return [deleteAction]
    }
    
}
