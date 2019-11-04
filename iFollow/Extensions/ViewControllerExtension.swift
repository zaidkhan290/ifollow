//
//  ViewControllerExtension.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func pushToVC(vc: UIViewController){
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
}
