//
//  ExploreViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var recentStoriesCollectionView: UICollectionView!
    @IBOutlet weak var allStoriesCollectionView: UICollectionView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "What are you looking for?", color: Theme.searchFieldColor)
        
        let storyCell = UINib(nibName: "StoryCollectionViewCell", bundle: nil)
        self.recentStoriesCollectionView.register(storyCell, forCellWithReuseIdentifier: "StoryCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 130, height: self.recentStoriesCollectionView.frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.recentStoriesCollectionView.collectionViewLayout = layout
        self.recentStoriesCollectionView.showsHorizontalScrollIndicator = false
        
        let allStoryCell = UINib(nibName: "AllStoriesCollectionViewCell", bundle: nil)
        self.allStoriesCollectionView.register(allStoryCell, forCellWithReuseIdentifier: "AllStories")
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.minimumInteritemSpacing = 0
        layout2.itemSize = CGSize(width: 120, height: (self.allStoriesCollectionView.bounds.height / 2) - 35)
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.allStoriesCollectionView.collectionViewLayout = layout2
        self.allStoriesCollectionView.showsHorizontalScrollIndicator = false
    }
    
    //MARK:- Methods
    
    func openCamera(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == recentStoriesCollectionView){
            
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
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllStories", for: indexPath) as! AllStoriesCollectionViewCell
            if (indexPath.row % 2 == 0){
                cell.storyImage.image = UIImage(named: "Rectangle 10")
            }
            else{
                cell.storyImage.image = UIImage(named: "Rectangle 11")
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath.row == 0 && collectionView == recentStoriesCollectionView){
            self.openCamera()
        }
    }
    
}

extension ExploreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
