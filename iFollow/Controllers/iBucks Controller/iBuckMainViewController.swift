//
//  iBuckMainViewControlleeer.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

class iBuckMainViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var currentBuckView: UIView!
    
    var buyImages = ["buyIcon", "sendIcon" ,"sellIcon"]
    var buyTile = ["iBuy", "iSend", "iSell"]
    var buyDesc = ["Buy silver, gold & platinium packages", "Send Money to any of your Friends", "Exchange coins with real money"]
    
    override func viewDidLoad() {
        self.tblView.register(UINib(nibName: "iBucksTableViewCell", bundle: nil), forCellReuseIdentifier: "iBucksTableViewCell")
        self.valueView.layer.cornerRadius = 15
        self.currentBuckView.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showTabBar"), object: nil)
    }
}

extension iBuckMainViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iBucksTableViewCell", for: indexPath) as! iBucksTableViewCell
        cell.buyImageView.image = UIImage(named: buyImages[indexPath.row])
        cell.titleLbl.text = buyTile[indexPath.row]
        cell.descLbl.text = buyDesc[indexPath.row]
        cell.valueLbll.isHidden = true
        cell.selectionStyle = .none                                                                                                             
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideTabBar"), object: nil)
        if indexPath.row == 0{
            let vc = Utility.getiBuckBuyController()
            self.pushToVC(vc: vc)
        }else if indexPath.row == 1{
            let vc = Utility.getiBuckSendController()
            self.pushToVC(vc: vc)
        }else{
            let vc = Utility.getiBuckSellController()
            self.pushToVC(vc: vc)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
