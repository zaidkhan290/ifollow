//
//  StatusPostDetailViewController.swift
//  iFollow
//
//  Created by BSQP on 18/11/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class StatusPostDetailViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtViewStatus: UITextView!
    
    var status = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViewStatus.text = status
    }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
