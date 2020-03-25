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
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Actions
    
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
