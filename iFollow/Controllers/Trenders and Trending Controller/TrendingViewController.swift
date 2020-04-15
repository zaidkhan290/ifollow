//
//  TrendingViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class TrendingViewController: UIViewController {

    @IBOutlet weak var trendingTableView: UITableView!
    var selectedIndex = 0
    var trendingArray = [PostLikesUserModel]()
    var userId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        trendingTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        trendingTableView.rowHeight = 60
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getTrendings()
    }
    
    func getTrendings(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["id": userId == 0 ? Utility.getLoginUserId() : userId]
        
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
                            self.trendingArray.append(model)
                        }
                        self.trendingTableView.reloadData()
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
    
    func sendTrendRequest(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["user_id": trendingArray[selectedIndex].userId]
        API.sharedInstance.executeAPI(type: .trendRequest, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.trendingArray[self.selectedIndex].userRequestStatus = "pending"
                    self.trendingTableView.reloadData()
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
    
    func showUnTrendPopup(){
        let vc = UIAlertController(title: "Untrend", message: "Are you sure you want to untrend \(trendingArray[selectedIndex].userFullName)?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                self.untrendUser()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func untrendUser(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["user_id": trendingArray[selectedIndex].userId]
        API.sharedInstance.executeAPI(type: .untrendUser, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.trendingArray[self.selectedIndex].userRequestStatus = ""
                    if (self.userId == Utility.getLoginUserId()){
                        self.trendingArray.remove(at: self.selectedIndex)
                        self.trendingTableView.deleteRows(at: [IndexPath(row: self.selectedIndex, section: 0)], with: .left)
                    }
                    self.trendingTableView.reloadData()
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

extension TrendingViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        let user = trendingArray[indexPath.row]
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        cell.btnSend.setTitle("Trending", for: .normal)
        cell.btnSend.backgroundColor = Theme.profileLabelsYellowColor
        cell.btnSend.setTitleColor(.white, for: .normal)
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: user.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        cell.lblUsername.text = user.userFullName
        cell.lblLastSeen.text = user.userCountry
        
        if (user.userId == Utility.getLoginUserId()){
            cell.btnSend.isHidden = true
        }
        else{
            cell.btnSend.isHidden = false
            if (user.userRequestStatus == ""){
                cell.btnSend.setTitle("Trend", for: .normal)
                cell.btnSend.backgroundColor = .white
                cell.btnSend.layer.borderWidth = 1
                cell.btnSend.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
                cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
            }
            else if (user.userRequestStatus == "success"){
                cell.btnSend.setTitle("Trending", for: .normal)
                cell.btnSend.backgroundColor = Theme.profileLabelsYellowColor
                cell.btnSend.setTitleColor(.white, for: .normal)
            }
            else{
                cell.btnSend.setTitle("Untrend", for: .normal)
                cell.btnSend.backgroundColor = .white
                cell.btnSend.layer.borderWidth = 1
                cell.btnSend.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
                cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (trendingArray[indexPath.row].userId != Utility.getLoginUserId()){
            let vc = Utility.getOtherUserProfileViewController()
            vc.userId = trendingArray[indexPath.row].userId
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}

extension TrendingViewController: FriendsTableViewCellDelegate{
    
    func btnSendTapped(indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if (trendingArray[indexPath.row].userRequestStatus == ""){
            sendTrendRequest()
        }
        else{
            showUnTrendPopup()
        }
    }
    
}
