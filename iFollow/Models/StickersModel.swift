//
//  StickersModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 20/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class StickersModel: Object{
    
    @objc dynamic var stickerId: Int = 0
    @objc dynamic var stickerTag: String = ""
    @objc dynamic var stickerImage: String = ""
    
    func updateModelWithJSON(json: JSON){
        stickerId = json["id"].intValue
        stickerTag = json["tag"].stringValue
        stickerImage = json["image"].stringValue.replacingOccurrences(of: "\\", with: "")
    }
    
    static func getAllStickers() -> [StickersModel]{
        let realm = try! Realm()
        return Array(realm.objects(StickersModel.self))
    }
    
}
