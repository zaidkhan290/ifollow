//
//  iBuckSendViewControllerr.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
import Loaf

class iBuckSendViewControllerr: UIViewController {
    
    @IBOutlet weak var keyBoardView: UIView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    
    var searchUsersArray = [SearchUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        searchTableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        searchTableView.rowHeight = 80
        searchTableView.separatorStyle = .none
        searchTableView.tableFooterView = UIView()
        self.keyBoardView.isHidden = true
        self.emailTxtField.inputAccessoryView = keyBoardView
        self.emailTxtField.returnKeyType = .search
    }
    
    //MARK:- Methods and Actions
    
    func setColors(){
        self.view.setColor()
        btnContinue.setiBuckViewsBackgroundColor()
        btnContinue.setiBuckButtonTextColor()
        self.searchTableView.reloadData()
    }
    
    @objc func searchUsers(){
        
        if (emailTxtField.text == ""){
            Loaf("Please search username or email", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
            }
            return
        }
        
        let params = ["name": emailTxtField.text!]
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
    
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        let vc = Utility.getiBuckSellController()
        vc.isForSend = true
        self.pushToVC(vc: vc)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}

extension iBuckSendViewControllerr: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
      
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTxtField.endEditing(true)
        searchUsers()
        return true
    }
}

extension iBuckSendViewControllerr: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        cell.backgroundColor = .clear
        let user = searchUsersArray[indexPath.row]
        cell.lblUsername.textColor = traitCollection.userInterfaceStyle == .dark ? .white : Theme.memberNameColor
        cell.lblUserMessage.textColor = traitCollection.userInterfaceStyle == .dark ? .white : Theme.memberNameColor
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
        let vc = Utility.getiBuckSellController()
        vc.isForSend = true
        vc.userId = searchUsersArray[indexPath.row].userId
        vc.userName = searchUsersArray[indexPath.row].userFullName
        self.pushToVC(vc: vc)
    }
}
