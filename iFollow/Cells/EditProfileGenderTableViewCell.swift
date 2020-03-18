//
//  EditProfileGenderTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol EditProfileGenderTableViewCellDelegate: class {
    func genderTapped(gender: String)
}

class EditProfileGenderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var manImage: UIImageView!
    @IBOutlet weak var girlImage: UIImageView!
    var delegate: EditProfileGenderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        manImage.layer.borderWidth = 1
        girlImage.layer.borderWidth = 1
        manImage.layer.borderColor = UIColor.clear.cgColor
        girlImage.layer.borderColor = UIColor.clear.cgColor
        manImage.layer.cornerRadius = 17
        girlImage.layer.cornerRadius = 17
        
        manImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maleTapped)))
        girlImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(girlTapped)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func maleTapped(){
        manImage.layer.borderColor = UIColor.black.cgColor
        girlImage.layer.borderColor = UIColor.clear.cgColor
        if (delegate != nil){
            self.delegate?.genderTapped(gender: "male")
        }
    }
    
    @objc func girlTapped(){
        girlImage.layer.borderColor = UIColor.black.cgColor
        manImage.layer.borderColor = UIColor.clear.cgColor
        if (delegate != nil){
            self.delegate?.genderTapped(gender: "female")
        }
    }
}
