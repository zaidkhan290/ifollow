//
//  AllChatsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class AllChatsListViewController: UIViewController {

    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    
    var isPrivateChat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (isPrivateChat){
            lblAlert.text = "Messages will be deleted if not read in 12 hours"
            searchView.dropShadow(color: Theme.privateChatBoxSearchBarColor)
            searchView.layer.cornerRadius = 25
            Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: .white)
            self.view.backgroundColor = .clear
        }
        else{
            lblAlert.text = ""
            searchView.dropShadow(color: .white)
            searchView.layer.cornerRadius = 25
            Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: Theme.searchFieldColor)
        }
        
        let cellNib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        chatListTableView.register(cellNib, forCellReuseIdentifier: "ChatListCell")
        chatListTableView.rowHeight = 80
        
    }

}

extension AllChatsListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        cell.backgroundColor = isPrivateChat ? .clear : .white
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Utility.getChatContainerViewController()
        vc.isFromGroupChat = false
        vc.isPrivateChat = isPrivateChat
        vc.chatId = "4-8"
        vc.userId = Utility.getLoginUserId() == 4 ? "8" : "4"
        vc.userName = Utility.getLoginUserId() == 4 ? "Mou Navi" : "Murtaza Fatani"
        vc.chatUserImage = Utility.getLoginUserId() == 4 ? "https://res.cloudinary.com/bsqp-tech/image/upload/v1584639782/a4xneb8gkmsieplcrted.jpg" : "https://res.cloudinary.com/bsqp-tech/image/upload/v1584616817/sbptfu6nsl4i14ftm0nj.jpg"
        self.pushToVC(vc: vc)
    }
    
}
