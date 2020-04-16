//
//  AddMembersViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 15/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

protocol AddMembersViewControllerDelegate: class {
    func membersAdded(membersArray: [PostLikesUserModel])
}

class AddMembersViewController: UIViewController {

    @IBOutlet weak var membersView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var membersTableView: UITableView!
    
    var trendingArray = [PostLikesUserModel]()
    var searchTrendingArray = [PostLikesUserModel]()
    var selectedUsersIds = [Int]()
    var delegate: AddMembersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        membersView.roundTopCorners(radius: 30)
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "Search", color: Theme.searchFieldColor)
        
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        membersTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        membersTableView.rowHeight = 60
        txtFieldSearch.addTarget(self, action: #selector(searchTextFieldTextChanged), for: .editingChanged)
        getTrendings()
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnAddTapped(_ sender: UIButton) {
        if (trendingArray.filter{$0.userSelected == true}.count > 0){
            self.goBack()
            if (delegate != nil){
                self.delegate!.membersAdded(membersArray: trendingArray.filter{$0.userSelected == true})
            }
        }
        else{
            Loaf("Please select atleast 1 member", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
        }
    }
    
    func getTrendings(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["id": Utility.getLoginUserId()]
        
        API.sharedInstance.executeAPI(type: .getTrendersAndTrendings, method: .get, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                DispatchQueue.main.async {
                    if (status == .success){
                        let users = result["trendings"].arrayValue
                        self.trendingArray.removeAll()
                        for user in users{
                            let model = PostLikesUserModel()
                            model.updateModelWithJSON(json: user)
                            if (self.selectedUsersIds.contains(model.userId)){
                                model.userSelected = true
                            }
                            self.trendingArray.append(model)
                        }
                        
                        self.membersTableView.reloadData()
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
    
    @objc func searchTextFieldTextChanged(){
        if (txtFieldSearch.text == ""){
            self.searchTrendingArray.removeAll()
        }
        else{
            self.searchTrendingArray = self.trendingArray.filter{$0.userFullName.localizedCaseInsensitiveContains(txtFieldSearch.text!)}
        }
        self.membersTableView.reloadData()
    }
    
}

extension AddMembersViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtFieldSearch.text == "" ? trendingArray.count : searchTrendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        let user = txtFieldSearch.text == "" ? trendingArray[indexPath.row] : searchTrendingArray[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.btnSend.isHidden = true
        cell.selectImage.isHidden = false
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: user.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        cell.lblUsername.text = user.userFullName
        cell.lblLastSeen.text = user.userCountry
        
        if (user.userSelected){
            cell.selectImage.image = UIImage(named: "select")
        }
        else{
            cell.selectImage.image = UIImage(named: "unselect")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (txtFieldSearch.text == ""){
            if (trendingArray[indexPath.row].userId != Utility.getLoginUserId()){
                let vc = Utility.getOtherUserProfileViewController()
                vc.userId = trendingArray[indexPath.row].userId
                self.present(vc, animated: true, completion: nil)
            }
        }
        else{
            if (searchTrendingArray[indexPath.row].userId != Utility.getLoginUserId()){
                let vc = Utility.getOtherUserProfileViewController()
                vc.userId = searchTrendingArray[indexPath.row].userId
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
}

extension AddMembersViewController: FriendsTableViewCellDelegate{
    func btnSendTapped(indexPath: IndexPath) {
        
        if (txtFieldSearch.text == ""){
            trendingArray[indexPath.row].userSelected = !trendingArray[indexPath.row].userSelected
        }
        else{
            searchTrendingArray[indexPath.row].userSelected = !searchTrendingArray[indexPath.row].userSelected
        }
        self.membersTableView.reloadData()
    }
}
