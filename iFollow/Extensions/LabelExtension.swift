//
//  LabelExtension.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    
    func setShadow(color: UIColor){
        self.textColor = color
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 1.0
    }
}
