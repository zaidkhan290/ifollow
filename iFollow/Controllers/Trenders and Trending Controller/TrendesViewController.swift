//
//  TrendesViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class TrendesViewController: UIViewController {

    @IBOutlet weak var trendesTableView: UITableView!
    var selectedIndex = [Int]()
    var userId = 0
    var trendersArray = [PostLikesUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        trendesTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        trendesTableView.rowHeight = 60
        
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
        
        cell.btnSend.setTitle("Trend", for: .normal)
        cell.btnSend.backgroundColor = .white
        cell.btnSend.layer.borderWidth = 1
        cell.btnSend.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
        
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
        }
        
//        if (selectedIndex.contains(indexPath.row)){
//            cell.btnSend.setTitle("Following", for: .normal)
//            cell.btnSend.backgroundColor = Theme.profileLabelsYellowColor
//            cell.btnSend.setTitleColor(.white, for: .normal)
//        }
//        else{
//            cell.btnSend.setTitle("Follow", for: .normal)
//            cell.btnSend.backgroundColor = .white
//            cell.btnSend.layer.borderWidth = 1
//            cell.btnSend.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
//            cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
//        }
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
        if !(selectedIndex.contains(indexPath.row)){
            selectedIndex.append(indexPath.row)
        }
        else{
            let indexToRemove = selectedIndex.firstIndex(of: indexPath.row)!
            selectedIndex.remove(at: indexToRemove)
        }
        self.trendesTableView.reloadData()
    }
    
}
