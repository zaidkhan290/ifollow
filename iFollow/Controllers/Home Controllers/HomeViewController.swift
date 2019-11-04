//
//  HomeViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var storyCollectionView: UICollectionView!
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserAddress: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var lblLikeComments: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var feedBackView: UIView!
    
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
        
        mainView.dropShadow(color: UIColor.white)
      //  mainView.backgroundColor = UIColor.lightGray
        mainView.layer.cornerRadius = 10
        userImage.layer.cornerRadius = 25
        
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
        }
        else{
            cell.userImage.isHidden = false
        }
        if(indexPath.row % 2 == 0){
            cell.storyImage.image = UIImage(named: "Rectangle 10")
        }
        else{
            cell.storyImage.image = UIImage(named: "Rectangle 11")
        }
        return cell
       
    }
    
}
