//
//  ExploreViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 05/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import FirebaseStorage
import Loaf

class ExploreViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var recentStoriesCollectionView: UICollectionView!
    @IBOutlet weak var allStoriesCollectionView: UICollectionView!
    
    var imagePicker = UIImagePickerController()
    var storageRef: StorageReference?
    var storyImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        //txtFieldSearch.isUserInteractionEnabled = false
       // searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchViewTapped)))
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
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        
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
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func searchViewTapped(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func saveStoryImageToFirebase(image: UIImage){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/StoryImage\(timeStemp).jgp")
        
        //        let imageData2 = UIImagePNGRepresentation(image)
        if let imageData2 = image.jpegData(compressionQuality: 1) {
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = picRef?.putData(imageData2, metadata: metadata, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    picRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
                            self.postStory(mediaUrl: imageURL.absoluteString, postType: "image")
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func saveStoryVideoToFirebase(videoURL: URL){
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Videos")
        let videoRef = iosRef?.child("/StoryVideo\(timeStemp).mov")
        
        if let videoData = try? Data(contentsOf: videoURL){
            
            Utility.showOrHideLoader(shouldShow: true)
            
            let uploadTask = videoRef?.putData(videoData, metadata: nil, completion: { (metaData, error) in
                if(error != nil){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    videoRef?.downloadURL(completion: { (url, error) in
                        if let videoURL = url{
                            self.postStory(mediaUrl: videoURL.absoluteString, postType: "video")
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func postStory(mediaUrl: String, postType: String){
        let params = ["media": mediaUrl,
                      "expire_hours": 48,
            "media_type": postType] as [String : Any]
        
        API.sharedInstance.executeAPI(type: .createStory, method: .post, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                Utility.showOrHideLoader(shouldShow: false)
                
                if (status == .success){
                    Loaf(message, state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .failure){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
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
                cell.storyImage.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "editProfilePlaceholder"))
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
                var storiesArray = [StoryModel]()
                
                let model1 = StoryModel()
                model1.storyId = 1
                model1.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585742103.mov?alt=media&token=5c66bb7e-6c0f-4a5f-82e6-d1402ab6357b"
                model1.storyMediaType = "video"
                model1.isWatched = false
                storiesArray.append(model1)
                
                let model2 = StoryModel()
                model2.storyId = 2
                model2.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1584621848.jgp?alt=media&token=9b21ae6b-43df-4545-bbe1-fd38017b5fdc"
                model2.storyMediaType = "image"
                model2.isWatched = false
                storiesArray.append(model2)
                
                let model3 = StoryModel()
                model3.storyId = 3
                model3.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585741866.mov?alt=media&token=015d7ed0-93bd-432c-b035-f8e42f59d822"
                model3.storyMediaType = "video"
                model3.isWatched = false
                storiesArray.append(model3)
                
                let model4 = StoryModel()
                model4.storyId = 4
                model4.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585654428.jgp?alt=media&token=89487b81-bc98-422f-80d5-143b00c5fdb0"
                model4.storyMediaType = "image"
                model4.isWatched = false
                storiesArray.append(model4)
                
                let vc = Utility.getStoriesViewController()
                vc.storiesArray = storiesArray
                let navVC = UINavigationController(rootViewController: vc)
                navVC.isNavigationBarHidden = true
                self.present(navVC, animated: true, completion: nil)
            }
        }
        else{
            var storiesArray = [StoryModel]()
            
            let model1 = StoryModel()
            model1.storyId = 1
            model1.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585742103.mov?alt=media&token=5c66bb7e-6c0f-4a5f-82e6-d1402ab6357b"
            model1.storyMediaType = "video"
            model1.isWatched = false
            storiesArray.append(model1)
            
            let model2 = StoryModel()
            model2.storyId = 2
            model2.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1584621848.jgp?alt=media&token=9b21ae6b-43df-4545-bbe1-fd38017b5fdc"
            model2.storyMediaType = "image"
            model2.isWatched = false
            storiesArray.append(model2)
            
            let model3 = StoryModel()
            model3.storyId = 3
            model3.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FVideos%2FStoryVideo1585741866.mov?alt=media&token=015d7ed0-93bd-432c-b035-f8e42f59d822"
            model3.storyMediaType = "video"
            model3.isWatched = false
            storiesArray.append(model3)
            
            let model4 = StoryModel()
            model4.storyId = 4
            model4.storyURL = "https://firebasestorage.googleapis.com/v0/b/ifollow-13644.appspot.com/o/Media%2FiOS%2FImages%2FStoryImage1585654428.jgp?alt=media&token=89487b81-bc98-422f-80d5-143b00c5fdb0"
            model4.storyMediaType = "image"
            model4.isWatched = false
            storiesArray.append(model4)
            
            let vc = Utility.getStoriesViewController()
            vc.storiesArray = storiesArray
            let navVC = UINavigationController(rootViewController: vc)
            navVC.isNavigationBarHidden = true
            self.present(navVC, animated: true, completion: nil)
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

extension ExploreViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage) {
        storyImage = image
        self.saveStoryImageToFirebase(image: storyImage)
    }
    
    func getStoryVideo(videoURL: URL) {
        self.saveStoryVideoToFirebase(videoURL: videoURL)
    }
}
