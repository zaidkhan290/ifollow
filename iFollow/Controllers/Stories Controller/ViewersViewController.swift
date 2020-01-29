//
//  ViewersViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 27/01/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol ViewersControllerDelegate {
    func viewersPopupDismissed()
}

class ViewersViewController: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    var delegate: ViewersControllerDelegate!
    var isForLike = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        friendsTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        friendsTableView.rowHeight = 60
        self.view.layer.cornerRadius = 20
        
        if (isForLike){
            lblHeading.text = "Post Trend Views"
            lblViews.text = "23 trends"
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.btnSend.isHidden = true
        cell.lblLastSeen.isHidden = true
        return cell
    }
    
}
