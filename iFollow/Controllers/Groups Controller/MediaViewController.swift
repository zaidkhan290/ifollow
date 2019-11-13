//
//  MediaViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 13/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import AppImageViewer

class MediaViewController: UIViewController {

    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    var mediaImages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mediaCellNib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        mediaCollectionView.register(mediaCellNib, forCellWithReuseIdentifier: "MediaCell")
        
        mediaImages = ["Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy", "Rectangle 15", "Layer 6 copy"]
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cellWidth = (UIScreen.main.bounds.width / 3) - 1
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        self.mediaCollectionView.collectionViewLayout = layout
        self.mediaCollectionView.showsVerticalScrollIndicator = false
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
}

extension MediaViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCollectionViewCell
        cell.mediaImage.image = UIImage(named: mediaImages[indexPath.row])
        cell.mediaImage.contentMode = .scaleAspectFill
        cell.mediaImage.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MediaCollectionViewCell
        let mediaImage = ViewerImage.appImage(forImage: UIImage(named: mediaImages[indexPath.row])!)
        let viewer = AppImageViewer(originImage: UIImage(named: mediaImages[indexPath.row])!, photos: [mediaImage], animatedFromView: cell)
        viewer.delegate = self

        self.present(viewer, animated: true, completion: nil)
        
    }
    
}

extension MediaViewController: AppImageViewerDelegate{
    
}
