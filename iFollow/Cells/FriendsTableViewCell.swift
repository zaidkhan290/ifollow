//
//  FriendsTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 11/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol FriendsTableViewCellDelegate: class {
    func btnSendTapped(indexPath: IndexPath)
}

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblLastSeen: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var selectImage: UIImageView!
    
    var delegate: FriendsTableViewCellDelegate!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectImage.isUserInteractionEnabled = true
        selectImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImageTapped)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton) {
        if (delegate != nil){
            self.delegate.btnSendTapped(indexPath: indexPath)
        }
    }
    
    @IBAction func btnOptionsTapped(_ sender: UIButton) {
    }
    
    @objc func selectImageTapped(){
        if (delegate != nil){
            self.delegate.btnSendTapped(indexPath: indexPath)
        }
    }
    
}
