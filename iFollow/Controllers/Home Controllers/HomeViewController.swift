//
//  HomeViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel

class HomeViewController: UIViewController {

    @IBOutlet weak var storyCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyCell = UINib(nibName: "StoryCollectionViewCell", bundle: nil)
        self.storyCollectionView.register(storyCell, forCellWithReuseIdentifier: "StoryCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 130, height: self.storyCollectionView.frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.storyCollectionView.collectionViewLayout = layout
        self.storyCollectionView.showsHorizontalScrollIndicator = false
        
        carouselView.type = .rotary
        self.carouselView.dataSource = self
        self.carouselView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        let storyCollectionHeight = (UIScreen.main.bounds.height) * (0.3)
//        self.storyCollectionViewHeightConstraint.constant = storyCollectionHeight
//        self.view.updateConstraintsIfNeeded()
//        self.view.layoutSubviews()
//        self.storyCollectionView.reloadData()
        
    }
    
    //MARK:- Methods
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCollectionViewCell
        
        if (indexPath.row == 0){
            cell.userImage.isHidden = true
            cell.addIcon.isHidden = false
        }
        else{
            cell.userImage.isHidden = false
            cell.addIcon.isHidden = true
        }
        if(indexPath.row % 2 == 0){
            cell.storyImage.image = UIImage(named: "Rectangle 10")
        }
        else{
            cell.storyImage.image = UIImage(named: "Rectangle 11")
        }
        return cell
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            self.openCamera()
        }
        else{
            let vc = Utility.getStoriesViewController()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

extension HomeViewController: iCarouselDataSource, iCarouselDelegate{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 10
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: carouselView.frame.width, height: carouselView.frame.height))
        
        let itemView = Bundle.main.loadNibNamed("FeedsView", owner: self, options: nil)?.first! as! FeedsView
        itemView.index = index
        itemView.userImage.isUserInteractionEnabled = true
        itemView.userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
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
    
//    func userImageTapped(index: Int) {
//        let vc = Utility.getOtherUserProfileViewController()
//        self.present(vc, animated: true, completion: nil)
//    }
    
    @objc func userImageTapped() {
        let vc = Utility.getOtherUserProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
}
