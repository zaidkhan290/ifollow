//
//  iBuckMainViewControlleeer.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 18/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Loaf

class iBuckMainViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var currentBuckView: UIView!
    @IBOutlet weak var lblCurrentBuck: UILabel!
    @IBOutlet weak var lblCurrentValue: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
    var buyImages = ["buyIcon", "sendIcon" ,"sellIcon"]
    var buyTile = ["iBuy", "iSend", "iSell"]
    var buyDesc = ["Buy coins", "Send Money to any of your Friends", "Exchange coins with real money"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setColors()
        self.tblView.register(UINib(nibName: "iBucksTableViewCell", bundle: nil), forCellReuseIdentifier: "iBucksTableViewCell")
        self.valueView.layer.cornerRadius = 15
        self.currentBuckView.layer.cornerRadius = 15
        self.valueView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showTabBar"), object: nil)
        getMyIBuck()
    }
    
    func setColors(){
        self.view.setColor()
        tblView.setColor()
        currentBuckView.setiBuckViewsBackgroundColor()
        valueView.setiBuckViewsBackgroundColor()
        lblCurrentBuck.setiBuckTextColor()
        lblValue.setiBuckTextColor()
        
    }
    
    func getMyIBuck(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .getMyiBuck, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                if (status == .success){
                    let myBuck = result["ibucks"].intValue
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        if let model = UserModel.getCurrentUser(){
                            model.userBuck = myBuck
                        }
                    }
                    self.lblCurrentValue.text = "\(Utility.getLoginUserBuck())"
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in

                    }
                    self.lblCurrentValue.text = "\(Utility.getLoginUserBuck())"
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setColors()
    }
}
