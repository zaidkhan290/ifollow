//
//  TrendingViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class TrendingViewController: UIViewController {

    @IBOutlet weak var trendingTableView: UITableView!
    var selectedIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        trendingTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        trendingTableView.rowHeight = 60
    }
    
}

extension TrendingViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        if (selectedIndex.contains(indexPath.row)){
            cell.btnSend.setTitle("Following", for: .normal)
            cell.btnSend.backgroundColor = Theme.profileLabelsYellowColor
            cell.btnSend.setTitleColor(.white, for: .normal)
        }
        else{
            cell.btnSend.setTitle("Follow", for: .normal)
            cell.btnSend.backgroundColor = .white
            cell.btnSend.layer.borderWidth = 1
            cell.btnSend.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
            cell.btnSend.setTitleColor(Theme.profileLabelsYellowColor, for: .normal)
        }
        return cell
    }
    
}

extension TrendingViewController: FriendsTableViewCellDelegate{
    
    func btnSendTapped(indexPath: IndexPath) {
        if !(selectedIndex.contains(indexPath.row)){
            selectedIndex.append(indexPath.row)
        }
        else{
            let indexToRemove = selectedIndex.firstIndex(of: indexPath.row)!
            selectedIndex.remove(at: indexToRemove)
        }
        self.trendingTableView.reloadData()
    }
    
}
