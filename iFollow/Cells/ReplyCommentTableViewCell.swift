//
//  ReplyCommentTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 30/09/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class ReplyCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserComment: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
