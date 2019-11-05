//
//  NotificationTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 35
        
        let notificationText = "John commented on your post"
        let range1 = notificationText.range(of: "John")
        let range2 = notificationText.range(of: "commented on your post")
        
        let attributedString = NSMutableAttributedString(string: notificationText)
        attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoBoldFontOfSize(size: 16.0), range: notificationText.nsRange(from: range1!))
        attributedString.addAttribute(NSAttributedString.Key.font, value: Theme.getLatoRegularFontOfSize(size: 16.0), range: notificationText.nsRange(from: range2!))
        lblNotification.attributedText = attributedString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Actions
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
    }
    
}
