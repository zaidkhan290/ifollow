//
//  ProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var lblTrends: UILabel!
    @IBOutlet weak var lblPosts: UILabel!
    @IBOutlet weak var privateTalkView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFiledSearch: UITextField!
    @IBOutlet weak var carouselView: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileView.roundTopCorners(radius: 30)
        editView.layer.cornerRadius = 15
        editView.layer.borderWidth = 1
        editView.layer.borderColor = UIColor.black.cgColor
        
        privateTalkView.layer.cornerRadius = 5
        privateTalkView.layer.borderWidth = 1
        privateTalkView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFiledSearch, placeholder: "What's in your mind?", color: Theme.searchFieldColor)
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
    }
    
    
    //MARk:- Actions
    
    @IBAction func btnMenuTapped(_ sender: UIButton) {
    }
    
}

extension ProfileViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 10
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.feedImage.clipsToBounds = true
        itemView.feedImage.image = UIImage(named: "iFollow-white-logo-1")
        itemView.feedImage.contentMode = .scaleAspectFit
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
}
