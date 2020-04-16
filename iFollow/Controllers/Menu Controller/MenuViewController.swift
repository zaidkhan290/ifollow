//
//  MenuViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import SDWebImage

class MenuViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    
    var menuItems = [String]()
    var menuIcons = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editView.layer.cornerRadius = 15
        editView.layer.borderWidth = 1
        editView.layer.borderColor = UIColor.white.cgColor
        editView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfileTapped)))
        
        let menuItemCellNib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        let menuSeperatorCellNib = UINib(nibName: "MenuSeperatorTableViewCell", bundle: nil)
        
        menuTableView.register(menuItemCellNib, forCellReuseIdentifier: "MenuCell")
        menuTableView.register(menuSeperatorCellNib, forCellReuseIdentifier: "MenuSeperatorTableViewCell")
        
        menuItems = ["Account Settings", "Privacy Settings", "Blocked Users", "Payments", "Geo Tagging", "", "Change Password", "Invite Friends", "Sign Out"]
        menuIcons = ["setting", "privacy", "friends", "credit-card", "map-location (1)", "", "password", "friends", "logout"]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUserData()
    }
    
    //MARK:- Actions
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Methods
    
    func setUserData(){
        userImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        userImage.layer.cornerRadius = userImage.frame.height / 2
        lblUsername.text = Utility.getLoginUserFullName()

    }
    
    @objc func editProfileTapped(){
        let vc = Utility.getEditProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func showLogoutPopup(){
        let vc = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            DispatchQueue.main.async {
                Utility.logoutUser()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        vc.addAction(yesAction)
        vc.addAction(noAction)
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuSeperatorTableViewCell", for: indexPath) as! MenuSeperatorTableViewCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
            cell.menuTitle.text = menuItems[indexPath.row]
            cell.menuIcon.image = UIImage(named: menuIcons[indexPath.row])
            cell.menuSwitch.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 5){
            return 20
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row == 1){
           let vc = Utility.getPrivacyViewController()
            self.pushToVC(vc: vc)
        }
        else if (indexPath.row == 2){
            let vc = Utility.getBlockUsersViewController()
            self.pushToVC(vc: vc)
        }
        else if (indexPath.row == 6){
            let vc = Utility.getSetPasswordViewController()
            self.pushToVC(vc: vc)
        }
        else if (indexPath.row == 8){
            showLogoutPopup()
        }
        
    }
}
