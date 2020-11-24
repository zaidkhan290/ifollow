//
//  PrivacyViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 24/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import RealmSwift

class PrivacyViewController: UIViewController {

    @IBOutlet weak var privacyTableView: UITableView!
    var menuItems = [String]()
    var menuIcons = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuItemCellNib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        privacyTableView.register(menuItemCellNib, forCellReuseIdentifier: "MenuCell")
        
        menuIcons = ["private_profile", "story_view", "post_trend", "display_trenders", "appointment" /*"story_view", "post_trend"*/]
        menuItems = ["Private Profile", "Story View", "Post Trend Views", "Display Trenders/Trendees", "Allow Appointments" /*"Story Expires Time", "Post Expires Time"*/]
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        updateUserSettingOnServer()
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    func updateUserSettingOnServer(){
        var settingVersion = Utility.getLoginUserSettingVersion()
        settingVersion = settingVersion + 1
        
        let realm = try! Realm()
        try! realm.safeWrite {
            if let model = UserModel.getCurrentUser(){
                model.userSettingVersion = settingVersion
            }
        }
        
        let params = ["post_hours": Utility.getLoginUserPostExpireHours(),
                      "story_hours": Utility.getLoginUserStoryExpireHours(),
                      "post_view": Utility.getLoginUserIsPostViewEnable(),
                      "story_view": Utility.getLoginUserIsStoryViewEnable(),
                      "profile_status": Utility.getLoginUserProfileType(),
                      "trend_status": Utility.getLoginUserDisplayTrendStatus(),
                      "allow_appointment": "\(Utility.getLoginUserIsAppointmentAllow())",
                      "version": settingVersion] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .updateUserSettings, method: .post, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
        }
    }

}

extension PrivacyViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
        cell.menuTitle.text = menuItems[indexPath.row]
        cell.menuIcon.image = UIImage(named: menuIcons[indexPath.row])
        cell.menuSwitch.tintColor = Theme.profileLabelsYellowColor
        cell.menuSwitch.onTintColor = Theme.profileLabelsYellowColor
        cell.delegate = self
        cell.indexPath = indexPath
        
        if (indexPath.row == 0){
            cell.menuSwitch.isHidden = false
            cell.menuSwitch.isOn = false
            cell.lblDuration.isHidden = true
            cell.btnMinus.isHidden = true
            cell.btnPlus.isHidden = true
            cell.menuSwitch.isOn = Utility.getLoginUserProfileType() == "private"
        }
        else if (indexPath.row == 1){
            cell.menuSwitch.isHidden = false
            cell.menuSwitch.isOn = false
            cell.lblDuration.isHidden = true
            cell.btnMinus.isHidden = true
            cell.btnPlus.isHidden = true
            cell.menuSwitch.isOn = Utility.getLoginUserIsStoryViewEnable() == 0
        }
        else if (indexPath.row == 2){
            cell.menuSwitch.isHidden = false
            cell.menuSwitch.isOn = false
            cell.lblDuration.isHidden = true
            cell.btnMinus.isHidden = true
            cell.btnPlus.isHidden = true
            cell.menuSwitch.isOn = Utility.getLoginUserIsPostViewEnable() == 0
            
        }
        else if (indexPath.row == 3){
            cell.menuSwitch.isHidden = false
            cell.menuSwitch.isOn = false
            cell.lblDuration.isHidden = true
            cell.btnMinus.isHidden = true
            cell.btnPlus.isHidden = true
            cell.menuSwitch.isOn = Utility.getLoginUserDisplayTrendStatus() == "public"
        }
        else if (indexPath.row == 4){
            cell.menuSwitch.isHidden = false
            cell.menuSwitch.isOn = false
            cell.lblDuration.isHidden = true
            cell.btnMinus.isHidden = true
            cell.btnPlus.isHidden = true
            cell.menuSwitch.isOn = Utility.getLoginUserIsAppointmentAllow() == 1
        }
//        else if (indexPath.row == 4){
//            cell.menuSwitch.isHidden = true
//            cell.menuSwitch.isOn = true
//            cell.lblDuration.isHidden = false
//            cell.btnMinus.isHidden = false
//            cell.btnPlus.isHidden = false
//            cell.lblDuration.text = "\(Utility.getLoginUserStoryExpireHours())"
//            cell.btnMinus.isEnabled = Utility.getLoginUserStoryExpireHours() > 24
//            cell.btnPlus.isEnabled = Utility.getLoginUserStoryExpireHours() < 72
//        }
//        else if (indexPath.row == 5){
//            cell.menuSwitch.isHidden = true
//            cell.menuSwitch.isOn = true
//            cell.lblDuration.isHidden = false
//            cell.btnMinus.isHidden = false
//            cell.btnPlus.isHidden = false
//            cell.lblDuration.text = "\(Utility.getLoginUserPostExpireHours())"
//            cell.btnMinus.isEnabled = Utility.getLoginUserPostExpireHours() > 24
//            cell.btnPlus.isEnabled = Utility.getLoginUserPostExpireHours() < 72
//        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension PrivacyViewController: MenuTableViewCellDelegate{
    
    func switchChanged(isOn: Bool, indexPath: IndexPath) {
        
        let realm = try! Realm()
        try! realm.safeWrite {
            if (indexPath.row == 0){
                if let model = UserModel.getCurrentUser(){
                    model.userProfileStatus = isOn ? "private" : "public"
                }
            }
            else if (indexPath.row == 1){
                if let model = UserModel.getCurrentUser(){
                    model.isUserStoryViewEnable = isOn ? 0 : 1
                }
            }
            else if (indexPath.row == 2){
                if let model = UserModel.getCurrentUser(){
                    model.isUserPostViewEnable = isOn ? 0 : 1
                }
            }
            else if (indexPath.row == 3){
                if let model = UserModel.getCurrentUser(){
                    model.userTrendStatus = isOn ? "public" : "private"
                }
            }
            else if (indexPath.row == 4){
                if let model = UserModel.getCurrentUser(){
                    model.isAppointmentAllow = isOn ? 1 : 0
                }
            }
        }
        self.privacyTableView.reloadData()
    }
    
    func durationChanged(isPlus: Bool, indexPath: IndexPath) {
        let realm = try! Realm()
        try! realm.safeWrite {
            if let user = UserModel.getCurrentUser(){
                
                if (isPlus){
                    if (indexPath.row == 4){
                        if (user.userStoryExpireHours == 24){
                            user.userStoryExpireHours = 48
                        }
                        else if (user.userStoryExpireHours == 48){
                            user.userStoryExpireHours = 72
                        }
                    }
                    else if (indexPath.row == 5){
                        if (user.userPostExpireHours == 24){
                            user.userPostExpireHours = 48
                        }
                        else if (user.userPostExpireHours == 48){
                            user.userPostExpireHours = 72
                        }
                    }
                }
                else{
                    if (indexPath.row == 4){
                        if (user.userStoryExpireHours == 72){
                            user.userStoryExpireHours = 48
                        }
                        else if (user.userStoryExpireHours == 48){
                            user.userStoryExpireHours = 24
                        }
                    }
                    else if (indexPath.row == 5){
                        if (user.userPostExpireHours == 72){
                            user.userPostExpireHours = 48
                        }
                        else if (user.userPostExpireHours == 48){
                            user.userPostExpireHours = 24
                        }
                    }
                }
                
            }
        }
        self.privacyTableView.reloadData()
    }
}
