//
//  BlockUsersViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 10/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class BlockUsersViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var blockedUsersTableView: UITableView!
    var blockedUsersArray = [SearchUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.roundTopCorners(radius: 30)
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        blockedUsersTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        blockedUsersTableView.rowHeight = 60
        blockedUsersTableView.tableFooterView = UIView()
        getBlockedUsers()
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.goBack()
    }
    
    func getBlockedUsers(){
        
        Utility.showOrHideLoader(shouldShow: true)
        API.sharedInstance.executeAPI(type: .getBlockUsers, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    let users = result["message"].arrayValue
                    for user in users{
                        let model = SearchUserModel()
                        model.updateModelWithJSON(json: user)
                        self.blockedUsersArray.append(model)
                    }
                    self.blockedUsersTableView.reloadData()
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
  
    func showUnblockPopup(index: Int){
        let alertVC = UIAlertController(title: "Unblock", message: "Are you sure you want to unblock this user?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                let params = ["user_id": self.blockedUsersArray[index].userId]
                self.blockedUsersArray.remove(at: index)
                self.blockedUsersTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
                Loaf("user unblocked", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                    
                }
                self.blockedUsersTableView.reloadData()
                API.sharedInstance.executeAPI(type: .unblockUser, method: .post, params: params, completion: { (status, result, message) in
                    DispatchQueue.main.async {
                        if (status == .authError){
                            Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                                Utility.logoutUser()
                            }
                        }
                    }
                })
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

extension BlockUsersViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        let user = blockedUsersArray[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.btnSend.setTitle("Unblock", for: .normal)
        cell.btnSend.backgroundColor = .white
        cell.btnSend.layer.borderWidth = 1
        cell.btnSend.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
        cell.lblUsername.text = user.userFullName
        cell.lblLastSeen.text = user.userName
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.sd_setImage(with: URL(string: user.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        return cell
    }
    
}

extension BlockUsersViewController: FriendsTableViewCellDelegate{
    
    func btnSendTapped(indexPath: IndexPath) {
        self.showUnblockPopup(index: indexPath.row)
    }
    
}
