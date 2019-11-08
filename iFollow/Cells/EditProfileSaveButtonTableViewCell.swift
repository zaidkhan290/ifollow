//
//  EditProfileSaveButtonTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol EditProfileDelegate: class {
    func btnDoneTapped()
}

class EditProfileSaveButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var btnDone: UIButton!
    var delegate: EditProfileDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnDone.dropShadow(color: Theme.editProfileDoneButtonColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        if (delegate != nil){
            self.delegate.btnDoneTapped()
        }
    }
    
}
