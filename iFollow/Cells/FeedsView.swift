//
//  FeedsView.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

protocol FeedsViewDelegate: class {
    func userImageTapped(index: Int)
}

class FeedsView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserAddress: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var lblLikeComments: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var postlikeView: UIView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var postTrendLikeIcon: UIImageView!
    
    var index: Int!
    var delegate: FeedsViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit(){
        
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
       
      //  Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)
        
//        mainView.dropShadow(color: UIColor.white)
//        //  mainView.backgroundColor = UIColor.lightGray
//        mainView.layer.cornerRadius = 10
//        userImage.layer.cornerRadius = 25
    }
    
    @objc func userImageTapped(){
        if (delegate != nil){
            self.delegate.userImageTapped(index: index)
        }
    }
}
