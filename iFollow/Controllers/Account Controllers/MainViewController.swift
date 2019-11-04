//
//  MainViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 01/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        let vc = Utility.getLoginViewController()
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        let vc = Utility.getSignupViewController()
        self.pushToVC(vc: vc)
    }
    
    
}
