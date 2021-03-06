//
//  TrendersContainerViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 12/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class TrendersContainerViewController: UIViewController {

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var trendersView: UIView!
    @IBOutlet weak var trendersSelectedView: UIView!
    @IBOutlet weak var trendingView: UIView!
    @IBOutlet weak var trendingSelectedView: UIView!
    @IBOutlet weak var lblTrenders: UILabel!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var selectedIndex = 0
    var trendesController = UIViewController()
    var trendingController = UIViewController()
    var firstTabTitle = ""
    var secondTabTitle = ""
    var userId = 0
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColor()
        mainView.roundTopCorners(radius: 30)
        
        trendesController = Utility.getTrendesViewController()
        (trendesController as! TrendesViewController).userId = userId
        trendingController = Utility.getTrendingViewController()
        (trendingController as! TrendingViewController).userId = userId
        lblUsername.text = username
        lblTrenders.text = firstTabTitle
        lblTrending.text = secondTabTitle
        
        trendersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        trendingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendingTapped)))
        
        changeTab()
        
    }
   
    //MARK:- Actions
    
    func setupColor(){
        self.mainView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func trendesTapped(){
        selectedIndex = 0
        changeTab()
    }
    
    @objc func trendingTapped(){
        selectedIndex = 1
        changeTab()
    }
    
    func changeTab(){
        if (selectedIndex == 0){
            trendersSelectedView.isHidden = false
            trendingSelectedView.isHidden = true
            remove(asChildViewController: [trendingController])
            add(asChildViewController: trendesController)
        }
        else{
            trendersSelectedView.isHidden = true
            trendingSelectedView.isHidden = false
            remove(asChildViewController: [trendesController])
            add(asChildViewController: trendingController)
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewControllers: [UIViewController]) {
        
        for viewController in viewControllers{
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColor()
    }
    
}
