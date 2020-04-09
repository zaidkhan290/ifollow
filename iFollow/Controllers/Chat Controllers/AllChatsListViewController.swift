//
//  AllChatsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class AllChatsListViewController: UIViewController {

    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    
    var chatRef = rootRef
    var allChatsArray = [RecentChatsModel]()
    var chatsArray = [RecentChatsModel]()
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
        
        let cellNib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        chatListTableView.register(cellNib, forCellReuseIdentifier: "ChatListCell")
        chatListTableView.rowHeight = 80
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
                                
                                Utility.showOrHideLoader(shouldShow: false)
                                self.chatsArray = self.allChatsArray.filter({$0.lastMessage != ""})
                                self.chatsArray.sort(by: { (model1, model2) -> Bool in
                                    return model1.lastMessageTime > model2.lastMessageTime
                                })
                                self.chatListTableView.reloadData()
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

}

extension AllChatsListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        cell.backgroundColor = isPrivateChat ? .clear : .white
        let chat = chatsArray[indexPath.row]
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: chat.chatUserImage), placeholderImage: UIImage(named: "img_placeholder"))
        cell.lblUsername.text = chat.chatUserName
        cell.lblUserMessage.text = chat.lastMessage
        cell.lblMessageCounter.isHidden = true
        cell.messageCounterIcon.isHidden = chat.isRead
        let lastMessageDate = Date(timeIntervalSince1970: (chat.lastMessageTime / 1000))
        cell.lblTime.text = Utility.getNotificationTime(date: lastMessageDate)
        cell.lblUserMessage.font = chat.isRead ? Theme.getLatoRegularFontOfSize(size: 12) : Theme.getLatoBoldFontOfSize(size: 12)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Utility.getChatContainerViewController()
        let chat = chatsArray[indexPath.row]
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
    
}
