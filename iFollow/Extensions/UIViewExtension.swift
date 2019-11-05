//
//  UIViewExtension.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func dropShadow(color: UIColor){
        self.backgroundColor = color
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1.0
    }
    
    func roundTopCorners(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
