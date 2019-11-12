//
//  SendStoryViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 11/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol SendStoryViewControllerDelegate {
    func sendStoryPopupDismissed()
}

class SendStoryViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    var delegate: SendStoryViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 20
        
        searchView.layer.borderWidth = 1
        searchView.layer.borderColor = UIColor.black.cgColor
        searchView.layer.cornerRadius = 5
        
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        friendsTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        friendsTableView.rowHeight = 60
    }
    
    //MARK:- Actions
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        if (delegate != nil){
            self.delegate.sendStoryPopupDismissed()
        }
    }

}

extension SendStoryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        return cell
    }
    
}
