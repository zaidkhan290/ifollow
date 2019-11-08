//
//  OtherUserProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel

class OtherUserProfileViewController: UIViewController, UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var lblTrending: UILabel!
    @IBOutlet weak var lblTrend: UILabel!
    @IBOutlet weak var lblTrends: UILabel!
    @IBOutlet weak var lblPosts: UILabel!
    @IBOutlet weak var privateTalkView: UIView!
    @IBOutlet weak var trendView: UIView!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var optionsPickerView: UIPickerView!
    
    var isTrending = false
    var options = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileView.roundTopCorners(radius: 30)
        privateTalkView.layer.cornerRadius = 5
        privateTalkView.layer.borderWidth = 1
        privateTalkView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        privateTalkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privateTalkTapped)))
        
        trendView.layer.cornerRadius = 5
        trendView.layer.borderWidth = 1
        trendView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
        trendView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendViewTapped)))
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
        options = ["Block", "Report", "Copy User Url", "Private Talk"]
    }
    
    //MARK:- Actions
    
    @IBAction func optionsTapped(_ sender: Any) {
        showOptionsPopup()
    }
    
    func showOptionsPopup(){
        
        let vc = Utility.getOptionsViewController()
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 150, height: 200)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = optionsView
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func privateTalkTapped(){
        
    }
    
    @objc func trendViewTapped(){
        isTrending = !isTrending
        lblTrend.textColor = isTrending ? .white : Theme.profileLabelsYellowColor
        lblTrend.text = isTrending ? "Trending" : "Trend"
        trendView.backgroundColor = isTrending ? Theme.profileLabelsYellowColor : .white
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

}

extension OtherUserProfileViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 10
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.feedImage.clipsToBounds = true
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
}
