//
//  AllStoriesCollectionViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class AllStoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyImage.layer.cornerRadius = 5.0
        storyImage.dropShadow(color: .clear)
        userImage.layer.cornerRadius = 25.0
    }

}
