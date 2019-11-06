//
//  AllChatsListViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class AllChatsListViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: Theme.searchFieldColor)
        
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
        return cell
        
    }
    
}
