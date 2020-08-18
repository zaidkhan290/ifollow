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
import EmptyDataSet_Swift
import PullToRefresh

class NotificationViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationTableView: UITableView!
    var notifications = [NotificationModel]()
    let refresher = PullToRefresh()
    
    var storyUserArray = [StoryUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.setShadow(color: .white)
        notificationView.roundTopCorners(radius: 30)
        
        let cellNib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationTableView.register(cellNib, forCellReuseIdentifier: "NotificationCell")
        notificationTableView.emptyDataSetSource = self
        notificationTableView.emptyDataSetDelegate = self
        self.notificationTableView.addPullToRefresh(refresher) {
            self.getNotifications(isForRefresh: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetNotificationCount()
        getNotifications(isForRefresh: false)
    }
    
    func resetNotificationCount(){
        API.sharedInstance.executeAPI(type: .resetNotificationCount, method: .post, params: nil) { (status, result, message) in
            
        }
    }
    
    func getNotifications(isForRefresh: Bool){
        
        if (!isForRefresh){
            Utility.showOrHideLoader(shouldShow: true)
        }
        self.notificationTableView.isUserInteractionEnabled = false
        
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
        self.notificationTableView.endRefreshing(at: .top)
        self.notificationTableView.isUserInteractionEnabled = true
        self.notificationTableView.reloadData()
    }
    
    func respondToNotification(params: [String:Any], isAccept: Bool){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: isAccept ? .acceptTrendRequest : .rejectTrendRequest, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                    self.getNotifications(isForRefresh: false)
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
    
    func getSingleStory(storyId: Int){
        
        Utility.showOrHideLoader(shouldShow: true)
        
        let params = ["story_id": storyId]
        
        API.sharedInstance.executeAPI(type: .getSingleStory, method: .get, params: params) { (status, result, message) in
            DispatchQueue.main.async {
                
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    self.storyUserArray.removeAll()
                    let stories = result["message"].arrayValue
                    for story in stories{
                        let storyUserModel = StoryUserModel()
                        storyUserModel.updateModelWithJSON(json: story, isForMyStory: false, isPublicStory: false)
                        self.storyUserArray.append(storyUserModel)
                        
                        let vc = Utility.getSingleStoryViewController()
                        vc.isForMyStory = false
                        vc.isForPublicStory = false
                        vc.isFromExplore = true
                        vc.storiesUsersArray = self.storyUserArray
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.isNavigationBarHidden = true
                        navVC.modalPresentationStyle = .fullScreen
                        self.present(navVC, animated: true, completion: nil)
                    }
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
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
        cell.lblNotification.font = Theme.getLatoRegularFontOfSize(size: 16.0)
        cell.lblTime.text = Utility.timeAgoSince(Utility.getNotificationDateFrom(dateString: notification.notificationDate))
        cell.btnMinus.isHidden = !(notification.notificationTag == "1")
        cell.btnPlus.isHidden = !(notification.notificationTag == "1")
        let notificationText = "\(notification.notificationFriendName)\(notification.notificationMessage)"
        let range1 = notificationText.range(of: notification.notificationFriendName)
        let attributedString = NSMutableAttributedString(string: notificationText)
        if (range1 == nil){
            cell.lblNotification.attributedText = attributedString
        }
        else{
            attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoBoldFontOfSize(size: 16.0), range: notificationText.nsRange(from: range1!))
            cell.lblNotification.attributedText = attributedString
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        if (notification.notificationTag == "3"){
            let vc = Utility.getPostDetailViewController()
            vc.postId = notification.notificationRequestId
            self.present(vc, animated: true, completion: nil)
        }
        else if (notification.notificationTag == "7"){
            self.getSingleStory(storyId: notification.notificationRequestId)
        }
        else{
            if notification.notificationFriendId != 0{
                let vc = Utility.getOtherUserProfileViewController()
                vc.userId = notification.notificationFriendId
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension NotificationViewController: NotificationTableViewCellDelegate{
    
    func respondToRequest(indexPath: IndexPath, isAccept: Bool) {
        let notification = notifications[indexPath.row]
        let params = isAccept ? ["id": notification.notificationId,
                                 "request_id": notification.notificationRequestId,
                                 "name": notification.notificationFriendName] :
            ["id": notification.notificationId,
             "request_id": notification.notificationRequestId]
        self.respondToNotification(params: params, isAccept: isAccept)
    }
    
    func userImageTapped(indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let vc = Utility.getOtherUserProfileViewController()
        vc.userId = notification.notificationFriendId
        self.present(vc, animated: true, completion: nil)
    }
}


extension NotificationViewController: EmptyDataSetSource, EmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "No Notifications"
        let attributedText = NSMutableAttributedString(string: text)
        let range = text.range(of: text)
        attributedText.addAttributes([NSAttributedString.Key.font : Theme.getLatoBoldFontOfSize(size: 22), NSAttributedString.Key.foregroundColor : UIColor.black], range: text.nsRange(from: range!))
        return attributedText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "no-notification")
    }
}
