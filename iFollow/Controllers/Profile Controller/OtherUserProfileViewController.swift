//
//  OtherUserProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel

class OtherUserProfileViewController: UIViewController {

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
    }
    
    //MARK:- Actions
    
    @IBAction func optionsTapped(_ sender: Any) {
        
//        let attributedString = NSAttributedString(string: "What to do?", attributes: [
//            NSAttributedString.Key.font : Theme.getLatoBoldFontOfSize(size: 24), //your font here
//            NSAttributedString.Key.foregroundColor : Theme.profileLabelsYellowColor
//            ])
//        
//        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
//        alertController.setValue(attributedString, forKey: "attributedTitle")
//        alertController.view.backgroundColor = .white
//        alertController.view.roundTopCorners(radius: 10)
//        
//        let blockAction = UIAlertAction(title: "Block", style: .default) { (action) in
//        
//        }
//        blockAction.setValue(Theme.profileLabelsYellowColor, forKey: "titleTextColor")
//        
//        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
//            
//        }
//        reportAction.setValue(Theme.profileLabelsYellowColor, forKey: "titleTextColor")
//        
//        let copyAction = UIAlertAction(title: "Copy Users URL", style: .default) { (action) in
//            
//        }
//        copyAction.setValue(Theme.profileLabelsYellowColor, forKey: "titleTextColor")
//        
//        let privateAction = UIAlertAction(title: "Private Talk", style: .default) { (action) in
//            
//        }
//        privateAction.setValue(Theme.profileLabelsYellowColor, forKey: "titleTextColor")
//        
//        alertController.addAction(blockAction)
//        alertController.addAction(reportAction)
//        alertController.addAction(copyAction)
//        alertController.addAction(privateAction)
//        
//        self.present(alertController, animated: true, completion: nil)
        
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
