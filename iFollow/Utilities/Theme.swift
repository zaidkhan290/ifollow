//
//  Theme.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    
    static let textFieldColor = UIColor.init(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1.0)
    static let searchFieldColor = UIColor.init(red: 179.0/255.0, green: 185.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    
    static func getLatoRegularFontOfSize(size: CGFloat) -> UIFont{
        return UIFont(name: "Lato-Regular", size: size)!
    }
    
    static func getLatoBoldFontOfSize(size: CGFloat) -> UIFont{
        return UIFont(name: "Lato-Bold", size: size)!
    }
    
    static func getLatoSemiBoldOfSize(size: CGFloat) -> UIFont{
        return UIFont(name: "Lato-Semibold", size: size)!
    }
    
    static func getLatoBlackOfSize(size: CGFloat) -> UIFont{
        return UIFont(name: "Lato-Black", size: size)!
    }
    
}
