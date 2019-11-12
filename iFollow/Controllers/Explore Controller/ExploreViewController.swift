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
        txtFieldSearch.isUserInteractionEnabled = false
        searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchViewTapped)))
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
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image" /*"public.movie"*/]
        imagePicker.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let allStoryCell = UINib(nibName: "AllStoriesCollectionViewCell", bundle: nil)
        self.allStoriesCollectionView.register(allStoryCell, forCellWithReuseIdentifier: "AllStories")
        
        let cellHeight = (allStoriesCollectionView.bounds.height) / 2
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.minimumInteritemSpacing = 0
        layout2.itemSize = CGSize(width: 120, height: cellHeight)
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.allStoriesCollectionView.collectionViewLayout = layout2
        self.allStoriesCollectionView.showsHorizontalScrollIndicator = false
        self.allStoriesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .right, animated: false)

    }
    
    //MARK:- Methods
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func searchViewTapped(){
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
        
        if (collectionView == recentStoriesCollectionView){
            if (indexPath.row == 0){
                self.openCamera()
            }
            else{
                let vc = Utility.getStoriesViewController()
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
}

extension ExploreViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension ExploreViewController: PostViewControllerDelegate{
    
    func postTapped(postView: UIViewController) {
        self.view.makeToast("Your post share successfully..")
        postView.dismiss(animated: true, completion: nil)
    }
    
    func imageTapped(postView: UIViewController) {
        postView.dismiss(animated: true, completion: nil)
        searchViewTapped()
    }
}

extension ExploreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let vc = Utility.getNewPostViewController()
            vc.postSelectedImage = pickedImage
            vc.delegate = self
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
