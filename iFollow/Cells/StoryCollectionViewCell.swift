//
//  StoryCollectionViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        storyImage.layer.cornerRadius = 5.0
    }

}
