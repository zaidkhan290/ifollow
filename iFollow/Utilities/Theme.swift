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
    static let editProfileTextFieldColor = UIColor.init(red: 183.0/255.0, green: 183.0/255.0, blue: 183.0/255.0, alpha: 1.0)
    static let editProfileDoneButtonColor = UIColor.init(red: 237.0/255.0, green: 58.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    static let searchFieldColor = UIColor.init(red: 179.0/255.0, green: 185.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    static let profileLabelsYellowColor = UIColor.init(red: 241.0/255.0, green: 173.0/255.0, blue: 26.0/255.0, alpha: 1.0)
    static let privateChatContainerColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    static let privateChatBoxTabsColor = UIColor.init(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0)
    static let privateChatBoxSearchBarColor = UIColor.init(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    static let memberNameColor = UIColor.init(red: 93.0/255.0, green: 93.0/255.0, blue: 93.0/255.0, alpha: 1.0)
    static let privateChatOutgoingMessage = UIColor.init(red: 67.0/255.0, green: 67.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    static let privateChatIncomingMessage = UIColor.init(red: 103.0/255.0, green: 103.0/255.0, blue: 103.0/255.0, alpha: 1.0)
    static let privateChatBackgroundColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    static let feedsViewTimeColor = UIColor.init(red: 71.0/255.0, green: 83.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    
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
    
    static func getPictureEditFonts(fontName: String, size: CGFloat) -> UIFont{
        var font = ""
        if (fontName == "Rightland"){
            font = "Rightland"
        }
        else if (fontName == "Cream"){
            font = "CreamCake"
        }
        else if (fontName == "Janda"){
            font = "JandaCurlygirlSerif"
        }
        else if (fontName == "Simplisicky"){
            font = "SimplisickyFill"
        }
        else if (fontName == "Yellosun"){
            font = "yellosun"
        }
        else if (fontName == "LemonMilk"){
            font = "LEMONMILK-MediumItalic"
        }
        else if (fontName == "Gobold"){
            font = "GoboldLowplus"
        }
        else if (fontName == "Poetsen"){
            font = "PoetsenOne-Regular"
        }
        else if (fontName == "Evogria"){
            font = "Evogria-Italic"
        }
        return UIFont(name: font, size: size)!
    }
    
}
