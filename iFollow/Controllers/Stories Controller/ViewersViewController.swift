//
//  ViewersViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 27/01/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

protocol ViewersControllerDelegate {
    func viewersPopupDismissed()
}

class ViewersViewController: UIViewController {

    @IBOutlet weak var trendView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    var delegate: ViewersControllerDelegate!
    var isForLike = false
    var numberOfTrends = 0
    var postId = 0
    var trendUsers = [PostLikesUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        friendsTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        friendsTableView.rowHeight = 60
        self.trendView.clipsToBounds = true
        self.trendView.layer.cornerRadius = 20
        self.trendView.addShadow(shadowColor: UIColor.lightGray.cgColor, shadowOffset: CGSize(width: -5.0, height: -5.0), shadowOpacity: 0.4, shadowRadius: 3.0)
        
        if (isForLike){
            lblHeading.text = "Post Trend Views"
            lblViews.text = numberOfTrends > 1 ? "\(numberOfTrends) trends" : "\(numberOfTrends) trend"
            getPostTrends()
        }
        else{
            lblViews.text = ""
            getStoryViews()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func getStoryViews(){
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["id": postId]
        
        API.sharedInstance.executeAPI(type: .getStoryViews, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    let posts = result["message"].arrayValue
                    for post in posts{
                        let model = PostLikesUserModel()
                        model.updateModelWithJSON(json: post)
                        self.trendUsers.append(model)
                    }
                    self.lblViews.text = self.trendUsers.count > 1 ? "\(self.trendUsers.count) views" : "\(self.trendUsers.count) view"
                    self.friendsTableView.reloadData()
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
        }
    }
    
    func getPostTrends(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["id": postId]
        
        API.sharedInstance.executeAPI(type: .getPostTrends, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    let posts = result["message"].arrayValue
                    for post in posts{
                        let model = PostLikesUserModel()
                        model.updateModelWithJSON(json: post)
                        self.trendUsers.append(model)
                    }
                    self.friendsTableView.reloadData()
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
        }
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        if (delegate != nil){
            self.delegate.viewersPopupDismissed()
        }
    }
    
}

extension ViewersViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        
        let user = trendUsers[indexPath.row]
        cell.lblUsername.text = user.userFullName
        cell.lblLastSeen.text = user.userCountry
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.sd_setImage(with: URL(string: user.userImage), placeholderImage: UIImage(named: "img_placeholder"))
        cell.btnSend.isHidden = true
        cell.lblLastSeen.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (isForLike){
            let user = trendUsers[indexPath.row]
            if (user.userId != Utility.getLoginUserId()){
                let vc = Utility.getOtherUserProfileViewController()
                vc.userId = user.userId
                self.present(vc, animated: true, completion: nil)
                
            }
        }
        
    }
}
