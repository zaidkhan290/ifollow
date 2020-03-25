//
//  OtherUserProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel
import Lightbox

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
        
        lblTrends.isUserInteractionEnabled = true
        lblTrends.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendesTapped)))
        lblTrending.isUserInteractionEnabled = true
        lblTrending.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trendersTapped)))
        
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
    
    @objc func showFeedsOptionsPopup(sender: UIButton){
        
        let vc = Utility.getOptionsViewController()
        vc.options = ["Hide", "Share"]
        vc.isFromPostView = true
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 100, height: 100)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = sender
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func privateTalkTapped(){
        let vc = Utility.getChatContainerViewController()
        vc.isFromProfile = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func trendesTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.selectedIndex = 0
        vc.firstTabTitle = "TRENDERS"
        vc.secondTabTitle = "TRENDES"
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func trendersTapped(){
        let vc = Utility.getTrendersContainerViewController()
        vc.selectedIndex = 1
        vc.firstTabTitle = "TRENDERS"
        vc.secondTabTitle = "TRENDES"
        self.present(vc, animated: true, completion: nil)
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
        itemView.btnOptions.addTarget(self, action: #selector(showFeedsOptionsPopup(sender:)), for: .touchUpInside)
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let image = LightboxImage(image: UIImage(named: "Rectangle 15")!, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", videoURL: nil)
        let vc = LightboxController(images: [image], startIndex: 0)
        vc.pageDelegate = self
        vc.dismissalDelegate = self
        vc.dynamicBackground = true
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

extension OtherUserProfileViewController: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate{
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
