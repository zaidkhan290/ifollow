//
//  MediaViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 13/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import AppImageViewer
import DTPhotoViewerController
import AVKit
import AVFoundation

class MediaViewController: UIViewController {

    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    var mediaArray = [ChatMediaModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mediaCellNib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        mediaCollectionView.register(mediaCellNib, forCellWithReuseIdentifier: "MediaCell")
        
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
        return mediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCollectionViewCell
        let media = mediaArray[indexPath.row]
        cell.mediaImage.contentMode = .scaleAspectFill
        cell.mediaImage.layer.cornerRadius = 8
        
        if (media.mediaType == 2){
            cell.mediaImage.sd_setImage(with: URL(string: media.mediaUrl))
        }
        else if (media.mediaType == 3){
            cell.mediaImage.image = UIImage(named: "audio_icon")
        }
        else if (media.mediaType == 4){
            cell.mediaImage.image = UIImage(named: "video_icon")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MediaCollectionViewCell
        let media = mediaArray[indexPath.row]
        if (media.mediaType == 2){
            let viewController = DTPhotoViewerController(referencedView: cell.mediaImage, image: cell.mediaImage.image)
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        else if (media.mediaType == 3){
            let player = AVPlayer(url: URL(string: media.mediaUrl)!)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        else if (media.mediaType == 4){
            let player = AVPlayer(url: URL(string: media.mediaUrl)!)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
}

extension MediaViewController: DTPhotoViewerControllerDelegate{
    
}
