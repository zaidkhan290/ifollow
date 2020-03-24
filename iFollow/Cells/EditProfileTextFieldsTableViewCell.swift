//
//  EditProfileTextFieldsTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class EditProfileTextFieldsTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var txtViewSeperator: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
