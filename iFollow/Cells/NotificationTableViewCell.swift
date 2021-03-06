//
//  NotificationTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol NotificationTableViewCellDelegate: class {
    func respondToRequest(indexPath: IndexPath, isAccept: Bool)
    func userImageTapped(indexPath: IndexPath)
}

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    var delegate: NotificationTableViewCellDelegate?
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 35
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Methods and Actions
    
    @objc func userImageTapped(){
        if (delegate != nil){
            self.delegate!.userImageTapped(indexPath: indexPath)
        }
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        if (delegate != nil){
            self.delegate!.respondToRequest(indexPath: indexPath, isAccept: false)
        }
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        if (delegate != nil){
            self.delegate!.respondToRequest(indexPath: indexPath, isAccept: true)
        }
    }
    
}
