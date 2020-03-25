//
//  NotificationViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf
import RealmSwift

class NotificationViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationTableView: UITableView!
    var notifications = [NotificationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.setShadow(color: .white)
        notificationView.roundTopCorners(radius: 30)
        
        let cellNib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationTableView.register(cellNib, forCellReuseIdentifier: "NotificationCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getNotifications()
    }
    
    func getNotifications(){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .getNotifications, method: .get, params: nil) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    let realm = try! Realm()
                    let notifications = result["message"].arrayValue
                    try! realm.safeWrite {
                        realm.delete(realm.objects(NotificationModel.self))
                        for notification in notifications{
                            let model = NotificationModel()
                            model.updateModelWithJSON(json: notification)
                            realm.add(model)
                        }
                    }
                    self.setNotifications()
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.setNotifications()
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
    
    func setNotifications(){
        notifications = NotificationModel.getAllNotifications()
        self.notificationTableView.reloadData()
    }
    
    func respondToNotification(params: [String:Int], isAccept: Bool){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: isAccept ? .acceptTrendRequest : .rejectTrendRequest, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.getNotifications()
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
        
    }
    
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        let notification = notifications[indexPath.row]
        cell.userImage.sd_setImage(with: URL(string: notification.notificationFriendImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.clipsToBounds = true
        cell.lblNotification.text = notification.notificationMessage
        cell.lblNotification.font = Theme.getLatoRegularFontOfSize(size: 16.0)
        cell.lblTime.text = Utility.getNotificationTime(date: Utility.getNotificationDateFrom(dateString: notification.notificationDate))
        cell.btnMinus.isHidden = !(notification.notificationTag == "1")
        cell.btnPlus.isHidden = !(notification.notificationTag == "1")
        
//        if (indexPath.row == 0){
//            let notificationText = "John requested to trend you"
//            let range1 = notificationText.range(of: "John")
//            let range2 = notificationText.range(of: "requested to trend you")
//
//            let attributedString = NSMutableAttributedString(string: notificationText)
//            attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoBoldFontOfSize(size: 16.0), range: notificationText.nsRange(from: range1!))
//            attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoRegularFontOfSize(size: 16.0), range: notificationText.nsRange(from: range2!))
//            cell.lblNotification.attributedText = attributedString
//        }
//        else{
//            let notificationText = "John left feedback on your post"
//            let range1 = notificationText.range(of: "John")
//            let range2 = notificationText.range(of: "left feedback on your post")
//
//            let attributedString = NSMutableAttributedString(string: notificationText)
//            attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoBoldFontOfSize(size: 16.0), range: notificationText.nsRange(from: range1!))
//            attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoRegularFontOfSize(size: 16.0), range: notificationText.nsRange(from: range2!))
//            cell.lblNotification.attributedText = attributedString
//        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        if notification.notificationFriendId != 0{
            let vc = Utility.getOtherUserProfileViewController()
            vc.userId = notification.notificationFriendId
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension NotificationViewController: NotificationTableViewCellDelegate{
    
    func respondToRequest(indexPath: IndexPath, isAccept: Bool) {
        let notification = notifications[indexPath.row]
        let params = ["id": notification.notificationId,
                      "request_id": notification.notificationRequestId]
        self.respondToNotification(params: params, isAccept: isAccept)
    }
}
