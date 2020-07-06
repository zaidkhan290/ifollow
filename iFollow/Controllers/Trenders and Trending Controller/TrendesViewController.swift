//
//  TrendesViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import EmptyDataSet_Swift

class TrendesViewController: UIViewController {

    @IBOutlet weak var trendesTableView: UITableView!
    var selectedIndex = 0
    var userId = 0
    var trendersArray = [PostLikesUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        trendesTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        trendesTableView.rowHeight = 60
        trendesTableView.emptyDataSetSource = self
        trendesTableView.emptyDataSetDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getTrenders()
    }
    
    func getTrenders(){
        
        Utility.showOrHideLoader(shouldShow: true)
        let params = ["id": userId == 0 ? Utility.getLoginUserId() : userId]
        
        API.sharedInstance.executeAPI(type: .getTrendersAndTrendings, method: .get, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                DispatchQueue.main.async {
                    if (status == .success){
                        let users = result["trenders"].arrayValue
                        self.trendersArray.removeAll()
                        for user in users{
                            let model = PostLikesUserModel()
                            model.updateModelWithJSON(json: user)
                            self.trendersArray.append(model)
                        }
                        self.trendesTableView.reloadData()
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
        let params = ["user_id": trendersArray[selectedIndex].userId]
        API.sharedInstance.executeAPI(type: .trendRequest, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.trendersArray[self.selectedIndex].userRequestStatus = result["status"].stringValue
                    self.trendesTableView.reloadData()
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
        let vc = UIAlertController(title: "Untrend", message: "Are you sure you want to remove \(trendersArray[selectedIndex].userFullName) from your Trenders?", preferredStyle: .alert)
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
        let params = ["user_id": trendersArray[selectedIndex].userId]
        API.sharedInstance.executeAPI(type: .untrendUser, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.trendersArray[self.selectedIndex].userRequestStatus = ""
                    self.trendesTableView.reloadData()
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

extension TrendesViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        let user = trendersArray[indexPath.row]
        
        cell.indexPath = indexPath
        cell.delegate = self
        
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
        
        if (trendersArray[indexPath.row].userId != Utility.getLoginUserId()){
            let vc = Utility.getOtherUserProfileViewController()
            vc.userId = trendersArray[indexPath.row].userId
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}

extension TrendesViewController: FriendsTableViewCellDelegate{
    
    func btnSendTapped(indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if (trendersArray[indexPath.row].userRequestStatus == ""){
            sendTrendRequest()
        }
        else{
            showUnTrendPopup()
        }
    }
    
}

extension TrendesViewController: EmptyDataSetSource, EmptyDataSetDelegate{
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "no-trendees")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Trenders")
    }
    
}
