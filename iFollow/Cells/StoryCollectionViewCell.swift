//
//  StoryCollectionViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol StoryCollectionViewCellDelegate: class {
    func addStoryButtonTapped()
}

class StoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var addIcon: UIImageView!
    var delegate: StoryCollectionViewCellDelegate!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        storyImage.layer.cornerRadius = 5.0
        addIcon.isUserInteractionEnabled = true
        addIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addStoryIconTapped)))
    }
    
    @objc func addStoryIconTapped(){
        self.delegate!.addStoryButtonTapped()
    }

}
