//
//  FeedsView.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit(){
       
      //  Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)
        
//        mainView.dropShadow(color: UIColor.white)
//        //  mainView.backgroundColor = UIColor.lightGray
//        mainView.layer.cornerRadius = 10
//        userImage.layer.cornerRadius = 25
    }
    
}
