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

    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var lblAll: UILabel!
    @IBOutlet weak var allSelectedView: UIView!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var groupSelectedView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
   
    var delegate: SendStoryViewControllerDelegate!
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 20
        
        //searchView.layer.borderWidth = 1
       // searchView.layer.borderColor = UIColor.black.cgColor
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "Search", color: Theme.searchFieldColor)
        
        allView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allViewTapped)))
        groupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupViewTapped)))
        
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        friendsTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        friendsTableView.rowHeight = 60
        
        changeTab()
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
        
        if (selectedIndex == 0){
            lblAll.textColor = Theme.profileLabelsYellowColor
            allSelectedView.isHidden = false
            lblGroup.textColor = Theme.privateChatBoxTabsColor
            groupSelectedView.isHidden = true
        }
        else{
            lblGroup.textColor = Theme.profileLabelsYellowColor
            groupSelectedView.isHidden = false
            lblAll.textColor = Theme.privateChatBoxTabsColor
            allSelectedView.isHidden = true
        }
        
    }
    
}

extension SendStoryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.btnSend.backgroundColor = .white
        cell.btnSend.setTitle("", for: .normal)
        let sendImage = UIImage(named: "storySend")?.withRenderingMode(.alwaysOriginal)
        cell.btnSend.setImage(sendImage, for: .normal)
        return cell
    }
    
}
