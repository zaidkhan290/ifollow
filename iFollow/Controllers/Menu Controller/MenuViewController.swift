//
//  MenuViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

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
        
        menuItems = ["Account Settings", "Privacy Settings", "Payments", "Geo Tagging", "Story View", "Post Trend Views", "", "Create Group", "Office", "High School", "Family", "", "Change Password", "Invite Friends", "Sign Out"]
        menuIcons = ["setting", "privacy", "credit-card", "map-location (1)", "Group 7194", "Group 7194", "", "create-group-button", "groupIcon", "groupIcon", "groupIcon", "", "password", "friends", "logout"]
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editProfileTapped(){
        let vc = Utility.getEditProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 6 || indexPath.row == 11){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuSeperatorTableViewCell", for: indexPath) as! MenuSeperatorTableViewCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
            cell.menuTitle.text = menuItems[indexPath.row]
            cell.menuIcon.image = UIImage(named: menuIcons[indexPath.row])
            if (indexPath.row == 4 || indexPath.row == 5){
                cell.menuSwitch.isHidden = false
            }
            else{
                cell.menuSwitch.isHidden = true
            }
            cell.menuSwitch.isOn = false
            cell.menuSwitch.tintColor = Theme.profileLabelsYellowColor
            cell.menuSwitch.onTintColor = Theme.profileLabelsYellowColor
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 6 || indexPath.row == 11){
            return 20
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row == 12){
            let vc = Utility.getSetPasswordViewController()
            self.pushToVC(vc: vc)
        }
        else if (indexPath.row == 7){
            let vc = Utility.getCreateGroupViewController()
            self.pushToVC(vc: vc)
        }
        else if (indexPath.row == 14){
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name("logoutUser"), object: nil)
        }
        
    }
}
