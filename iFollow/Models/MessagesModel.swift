//
//  MessagesModel.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 20/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import SwiftyJSON

class MessagesModel: NSObject {
    
    var senderId: String = ""
    var senderDisplayName: String = ""
    var message: String = ""
    var messageTimeStamp: Double = 0.0
    var messageType: Int = 0
    var postId: Int = 0
    
}
