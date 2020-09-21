//
//  iBuckBuyViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

class iBuckBuyViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var buyImages = ["buyIcon", "buyIcon" ,"buyIcon"]
    var buyTile = ["50 Coins", "100 Coins", "500 Coins"]
    var buyDesc = ["Silver", "Gold", "Platinium"]
    
    override func viewDidLoad() {
        self.tblView.register(UINib(nibName: "iBucksTableViewCell", bundle: nil), forCellReuseIdentifier: "iBucksTableViewCell")
    }
    @IBAction func onBackClick(_ sender: Any) {
        self.goBack()
    }
}

extension iBuckBuyViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iBucksTableViewCell", for: indexPath) as! iBucksTableViewCell
        cell.buyImageView.image = UIImage(named: buyImages[indexPath.row])
        cell.titleLbl.text = buyTile[indexPath.row]
        cell.descLbl.text = buyDesc[indexPath.row]
        cell.valueLbll.isHidden = false
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

