//
//  PrivacyViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 24/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var privacyTableView: UITableView!
    var menuItems = [String]()
    var menuIcons = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuItemCellNib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        privacyTableView.register(menuItemCellNib, forCellReuseIdentifier: "MenuCell")
        
        menuIcons = ["Group 7194", "Group 7194", "Group 7194"]
        menuItems = ["Story View", "Post Trend Views", "Story Expires Time"]
        
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
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
        cell.menuSwitch.isHidden = false
        cell.menuSwitch.isOn = false
        cell.menuSwitch.tintColor = Theme.profileLabelsYellowColor
        cell.menuSwitch.onTintColor = Theme.profileLabelsYellowColor
        cell.menuSwitch.isHidden = indexPath.row == 2 ? true : false
        cell.btnPlus.isHidden = indexPath.row == 2 ? false : true
        cell.lblDuration.isHidden = indexPath.row == 2 ? false : true
        cell.btnMinus.isHidden = indexPath.row == 2 ? false : true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
