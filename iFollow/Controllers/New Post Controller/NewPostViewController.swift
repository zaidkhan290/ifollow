//
//  NewPostViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 11/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol PostViewControllerDelegate: class {
    func postTapped(postView: UIViewController)
    func imageTapped(postView: UIViewController)
}

class NewPostViewController: UIViewController {

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var txtFieldStatus: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var btnPic: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnBoost: UIButton!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var postViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblAddBudget: UILabel!
    @IBOutlet weak var budgetSlider: UISlider!
    @IBOutlet weak var lblMinBudget: UILabel!
    @IBOutlet weak var lblMaxBudget: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblPeoples: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var lblVisa: UILabel!
    @IBOutlet weak var btnBoostPost: UIButton!
    
    var isDetail = false
    var postSelectedImage = UIImage()
    var delegate: PostViewControllerDelegate!
    var days = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postView.layer.cornerRadius = 20
        postView.dropShadow(color: .white)
        postImage.image = postSelectedImage
        
        let peopleText = "10k - 20k People will saw this post"
        let range1 = peopleText.range(of: "10k - 20k")
        let range2 = peopleText.range(of: "People will saw this post")
        
        let attributedPeopleString = NSMutableAttributedString(string: peopleText)
        attributedPeopleString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: Theme.getLatoBoldFontOfSize(size: 14)], range: peopleText.nsRange(from: range1!))
        attributedPeopleString.addAttributes([NSAttributedString.Key.foregroundColor: Theme.privateChatBoxTabsColor, NSAttributedString.Key.font: Theme.getLatoRegularFontOfSize(size: 14)], range: peopleText.nsRange(from: range2!))
        lblPeoples.attributedText = attributedPeopleString
      
        let likeText = "2k - 4k Average of likes for this post"
        let rang1 = likeText.range(of: "2k - 4k")
        let rang2 = likeText.range(of: "Average of likes for this post")
        
        let attributedLikeString = NSMutableAttributedString(string: likeText)
        attributedLikeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: Theme.getLatoBoldFontOfSize(size: 14)], range: likeText.nsRange(from: rang1!))
        attributedLikeString.addAttributes([NSAttributedString.Key.foregroundColor: Theme.privateChatBoxTabsColor, NSAttributedString.Key.font: Theme.getLatoRegularFontOfSize(size: 14)], range: likeText.nsRange(from: rang2!))
        lblLike.attributedText = attributedLikeString
        
        let visaText = "Visa **7045"
        let visaRange1 = visaText.range(of: "Visa")
        let visaRange2 = visaText.range(of: "**7045")
        
        let attributedVisaString = NSMutableAttributedString(string: visaText)
        attributedVisaString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: Theme.getLatoBoldFontOfSize(size: 14)], range: visaText.nsRange(from: visaRange1!))
        attributedVisaString.addAttributes([NSAttributedString.Key.foregroundColor: Theme.privateChatBoxTabsColor, NSAttributedString.Key.font: Theme.getLatoRegularFontOfSize(size: 14)], range: visaText.nsRange(from: visaRange2!))
        lblVisa.attributedText = attributedVisaString
        
        lblDays.text = "\(days) Days"
        
        budgetSlider.minimumValue = 5
        budgetSlider.maximumValue = 100
        budgetSlider.value = 20
        lblAddBudget.text = "Add Budget ($20)"
        budgetSlider.addTarget(self, action: #selector(budgetSliderValueChange), for: .valueChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
      //  DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        //    self.changePostViewSize()
      //  }
        
    }
    
    //MARK:- Actions and Methods
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton) {
        if (delegate != nil){
            self.delegate.imageTapped(postView: self)
        }
    }
    
    @IBAction func btnLocationTapped(_ sender: UIButton) {
    }
    
    @objc func budgetSliderValueChange(){
        let budget = budgetSlider.value.rounded()
        let budgetString = String(format: "%.0f", budget)
        lblAddBudget.text = "Add Budget ($\(budgetString))"
    }
    
    @IBAction func btnBoostTapped(_ sender: UIButton) {
        changePostViewSize()
    }
    
    @IBAction func btnPostTapped(_ sender: UIButton){
        if (delegate != nil){
            self.delegate.postTapped(postView: self)
        }
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        if (days > 1 && days <= 7){
            days -= 1
        }
        lblDays.text = "\(days) Days"
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        if (days >= 1 && days < 7){
            days += 1
        }
        lblDays.text = "\(days) Days"
    }
    
    @IBAction func btnBoosPostTapped(_ sender: UIButton) {
    }
    
    func changePostViewSize(){
        
        isDetail = !isDetail
        btnBoost.setImage(UIImage(named: isDetail ? "promoteSelected" : "promote"), for: .normal)
        
        if (isDetail){
            postViewTopConstraint.constant = 30
            postViewHeightConstraint.constant = 600
        }
        else{
            postViewTopConstraint.constant = 100
            postViewHeightConstraint.constant = 280
        }
        self.postView.layer.cornerRadius = 20
        self.view.updateConstraintsIfNeeded()
        self.view.layoutSubviews()
        
    }
}
