//
//  EmojisViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/03/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol EmojisViewControllerDelegate: class{
    func emojiTapped(image: UIImage, isEmojis: Bool)
}

class EmojisViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var emojisCollectionView: UICollectionView!
    var emojis = [UIImage]()
    var stickers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var delegate: EmojisViewControllerDelegate!
    var isEmojis = false
    var stickersLayout = UICollectionViewFlowLayout()
    var emojisLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 20
        let ranges = [0x1F601...0x1F64F, 0x2702...0x27B0]
        emojis = ranges
            .flatMap { $0 }
            .compactMap { Unicode.Scalar($0) }
            .map(Character.init)
            .compactMap { String($0).image() }
        setupCollectionView()
    }

    func setupCollectionView(){
        
        
        emojisCollectionView.register(UINib(nibName: "EmojisCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmojisCollectionViewCell")
        
        stickersLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 30) / 3, height: 110)
        stickersLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        stickersLayout.minimumLineSpacing = 5
        stickersLayout.minimumInteritemSpacing = 5
        stickersLayout.scrollDirection = .vertical
        
        emojisLayout.itemSize = CGSize(width: 50, height: 50)
        emojisLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        emojisLayout.minimumLineSpacing = 5
        emojisLayout.minimumInteritemSpacing = 5
        emojisLayout.scrollDirection = .vertical
        self.emojisCollectionView.collectionViewLayout = stickersLayout
        self.emojisCollectionView.showsVerticalScrollIndicator = false
    }
    
    @IBAction func segmentControllChanged(_ sender: UISegmentedControl) {
        isEmojis = sender.selectedSegmentIndex == 1
        self.emojisCollectionView.collectionViewLayout = sender.selectedSegmentIndex == 0 ? stickersLayout : emojisLayout
        self.emojisCollectionView.reloadData()
    }
    
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EmojisViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (isEmojis){
            return emojis.count
        }
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (isEmojis){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojisCollectionViewCell", for: indexPath) as! EmojisCollectionViewCell
            cell.emojiImageView.image = emojis[indexPath.row]
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojisCollectionViewCell", for: indexPath) as! EmojisCollectionViewCell
            cell.emojiImageView.image = UIImage(named: stickers[indexPath.row])
            cell.emojiImageView.contentMode = .scaleAspectFill
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (isEmojis){
            let cell = collectionView.cellForItem(at: indexPath) as! EmojisCollectionViewCell
            let image = cell.emojiImageView.image!
            self.delegate.emojiTapped(image: image, isEmojis: true)
            self.dismiss(animated: true, completion: nil)
        }
        else{
            let image = UIImage(named: stickers[indexPath.row])
            self.delegate.emojiTapped(image: image!, isEmojis: false)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
