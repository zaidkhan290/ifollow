//
//  InstantPanGestureRecognizer.swift
//  Sample_Camerra
//
//  Created by Shahzeb siddiqui on 10/07/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit
class InstantPanGestureRecognizer: UIPanGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == .ended) || (self.state == .cancelled) { return }
        super.touchesEnded(touches, with: event);
        self.state = .ended
    }
}
