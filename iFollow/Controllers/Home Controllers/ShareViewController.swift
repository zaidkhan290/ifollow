//
//  ShareViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 17/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class ShareViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var trendingTableViews: UITableView!
    var trendingArray = [PostLikesUserModel]()
    var selectedIndex = [Int]()
    
    var postId = 0
    var postUserId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setColor()
        mainView.roundTopCorners(radius: 30)
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        trendingTableViews.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        trendingTableViews.rowHeight = 60
        trendingTableViews.tableFooterView = UIView()
        getTrendings()
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setColor(){
        self.mainView.setColor()
        self.trendingTableViews.reloadData()
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
                            if (model.userId != self.postUserId){
                                self.trendingArray.append(model)
                            }
                        }
                        self.trendingTableViews.reloadData()
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
    
    func sharePostToUser(userId: Int){
        
        let params = ["post_id": postId,
                      "user_id": userId]
        
        API.sharedInstance.executeAPI(type: .sharePost, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .authError){
                    
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColor()
    }
}

extension ShareViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        let user = trendingArray[indexPath.row]
        
        cell.btnSend.backgroundColor = .clear
        cell.delegate = self
        cell.indexPath = indexPath
        cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
        
        if (selectedIndex.contains(indexPath.row)){
            cell.btnSend.setImage(nil, for: .normal)
            cell.btnSend.setTitle("Shared", for: .normal)
        }
        else{
            cell.btnSend.setTitle("", for: .normal)
            let sendImage = UIImage(named: "storySend")?.withRenderingMode(.alwaysOriginal)
            cell.btnSend.setImage(sendImage, for: .normal)
        }
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: user.userImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        cell.lblUsername.text = user.userFullName
        cell.lblLastSeen.text = user.userCountry
        cell.lblLastSeen.textColor = traitCollection.userInterfaceStyle == .dark ? .white : Theme.memberNameColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Utility.getOtherUserProfileViewController()
        vc.userId = trendingArray[indexPath.row].userId
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ShareViewController: FriendsTableViewCellDelegate{
    func btnSendTapped(indexPath: IndexPath) {
        if !(selectedIndex.contains(indexPath.row)){
            selectedIndex.append(indexPath.row)
            self.sharePostToUser(userId: trendingArray[indexPath.row].userId)
        }
        self.trendingTableViews.reloadData()
    }
}
