//
//  SearchViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 09/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class SearchViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtfieldSearch: UITextField!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchTableView: UITableView!
    
    var searchUsersArray = [SearchUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtfieldSearch, placeholder: "Search users", color: Theme.searchFieldColor)
        txtfieldSearch.delegate = self
        searchTableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        searchTableView.rowHeight = 80
        searchTableView.separatorStyle = .none
        searchTableView.tableFooterView = UIView()
        
        searchIcon.isUserInteractionEnabled = true
        searchIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchUsers)))
        txtfieldSearch.becomeFirstResponder()
        
    }
    
    //MARK:- Actions and Methods

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func searchUsers(){
        
        if (txtfieldSearch.text == ""){
            Loaf("Please search user name", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
            return
        }
        
        let params = ["name": txtfieldSearch.text!]
        Utility.showOrHideLoader(shouldShow: true)
        searchUsersArray.removeAll()
        self.view.endEditing(true)
        
        API.sharedInstance.executeAPI(type: .searchUsers, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    let users = result["message"].arrayValue
                    for user in users{
                        let model = SearchUserModel()
                        model.updateModelWithJSON(json: user)
                        if (model.userId != Utility.getLoginUserId()){
                            self.searchUsersArray.append(model)
                        }
                    }
                    self.searchTableView.reloadData()
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        cell.backgroundColor = .clear
        let user = searchUsersArray[indexPath.row]
        cell.lblUsername.text = user.userFullName
        cell.lblUserMessage.text = user.userName
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.sd_setImage(with: URL(string: user.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        cell.lblMessageCounter.isHidden = true
        cell.lblTime.isHidden = true
        cell.messageCounterIcon.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Utility.getOtherUserProfileViewController()
        vc.userId = searchUsersArray[indexPath.row].userId
        self.present(vc, animated: true, completion: nil)
    }
}

extension SearchViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchUsers()
        return true
    }
}
