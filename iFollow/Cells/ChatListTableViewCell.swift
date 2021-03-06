//
//  ChatListTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMessageCounter: UILabel!
    @IBOutlet weak var messageCounterIcon: UIImageView!
    @IBOutlet weak var onlineIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
