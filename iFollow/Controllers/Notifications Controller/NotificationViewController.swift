//
//  NotificationViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.setShadow(color: .white)
        notificationView.roundTopCorners(radius: 30)
        
        let cellNib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationTableView.register(cellNib, forCellReuseIdentifier: "NotificationCell")
        notificationTableView.rowHeight = 80
        
    }
    
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        cell.btnMinus.isHidden = indexPath.row == 0 ? false : true
        cell.btnPlus.isHidden = indexPath.row == 0 ? false : true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = .white
        let header = view as! UITableViewHeaderFooterView
        header.backgroundColor = .white
        header.textLabel?.textColor = UIColor.black.withAlphaComponent(0.45)
        header.textLabel?.font = Theme.getLatoBlackOfSize(size: 27.0)
        
        if (section == 0){
            header.textLabel?.text = "Today"
        }
        else{
            header.textLabel?.text = "Yesterday"
        }
    }
    
}
