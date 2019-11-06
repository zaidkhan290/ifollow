//
//  CameraViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnRotate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCaptureTapped(_ sender: UIButton) {
    }
    
    @IBAction func btnFlashTapped(_ sender: UIButton) {
    }
    
    @IBAction func btnRotateTapped(_ sender: UIButton) {
    }
}
