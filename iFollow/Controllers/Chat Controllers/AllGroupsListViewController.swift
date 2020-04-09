//
//  AllGroupsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

import UIKit

class AllGroupsListViewController: UIViewController {
    
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    
    var isPrivateChat = false
    
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
        
        let cellNib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        chatListTableView.register(cellNib, forCellReuseIdentifier: "ChatListCell")
        chatListTableView.rowHeight = 80
        
    }
    
}

extension AllGroupsListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        cell.backgroundColor = isPrivateChat ? .clear : .white
        cell.userImage.image = UIImage(named: "family")
        cell.userImage.contentMode = .center
        cell.lblUsername.text = "Family Group"
        cell.lblUserMessage.text = "Watson, Pollan, Kane..(15 others)"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = Utility.getChatContainerViewController()
//        vc.isFromGroupChat = true
//        vc.isPrivateChat = isPrivateChat
//        self.pushToVC(vc: vc)
    }
    
}
