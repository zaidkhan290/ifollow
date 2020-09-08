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
import Photos

class MediaViewController: UIViewController {

    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    var mediaArray = [ChatMediaModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColor()
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
    
    func setupColor(){
        self.mediaView.setColor()
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @objc func showSaveMediaPopup(_ sender: UILongPressGestureRecognizer){
        
        if (mediaArray[sender.view!.tag].mediaType != 3){
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let saveMedia = UIAlertAction(title: "Save Media", style: .default) { (action) in
                DispatchQueue.main.async {
                    self.saveMediaToPhone(index: sender.view!.tag)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertVC.addAction(saveMedia)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    func saveMediaToPhone(index: Int){
        let mediaModel = self.mediaArray[index]
        if (mediaModel.mediaType == 2){
            //image
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: URL(string: mediaModel.mediaUrl)!){
                    if let image = UIImage(data: imageData){
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
            }
            
        }
        else if (mediaModel.mediaType == 4){
            //video
            DispatchQueue.global(qos: .background).async {
                if let url = URL(string: mediaModel.mediaUrl),
                    let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/\(UUID().uuidString).mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColor()
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
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showSaveMediaPopup(_:)))
        longPressGesture.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressGesture)
        
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
