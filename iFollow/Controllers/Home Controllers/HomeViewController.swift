//
//  HomeViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 04/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import iCarousel
import FirebaseStorage
import Loaf
import CoreLocation
import RealmSwift
import Lightbox

class HomeViewController: UIViewController {

    @IBOutlet weak var storyCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    var isFullScreen = false
    var storyImage = UIImage()
    var storageRef: StorageReference?
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    var userCurrentAddress = ""
    
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
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    //MARK:- Methods
    
    func openCamera(){
        let vc = Utility.getCameraViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func showOptionsPopup(sender: UIButton){
        
        let vc = Utility.getOptionsViewController()
        vc.options = ["Hide", "Share"]
        vc.isFromPostView = true
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 100, height: 100)
        
        let popup = vc.popoverPresentationController
        popup?.permittedArrowDirections = UIPopoverArrowDirection.up
        popup?.sourceView = sender
        popup?.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func saveStoryMediaToFirebase(image: UIImage){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/StoryImage\(timeStemp).jgp")
        
        //        let imageData2 = UIImagePNGRepresentation(image)
        if let imageData2 = image.jpegData(compressionQuality: 0.5) {
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
                            self.postStory(mediaUrl: imageURL.absoluteString)
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
    
    func postStory(mediaUrl: String){
        let params = ["media": mediaUrl,
                      "expire_hours": 48,
            "media_type": "image"] as [String : Any]
        
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

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
        itemView.feedBackView.isUserInteractionEnabled = true
        itemView.feedBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feedbackViewTapped)))
        itemView.postlikeView.isUserInteractionEnabled = true
        itemView.postlikeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postLikeViewTapped)))
        itemView.frame = view.frame
        itemView.userImage.layer.cornerRadius = 25
        itemView.feedImage.clipsToBounds = true
        itemView.mainView.dropShadow(color: .white)
        itemView.mainView.layer.cornerRadius = 10
        itemView.btnOptions.addTarget(self, action: #selector(showOptionsPopup(sender:)), for: .touchUpInside)
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(itemView)
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let image = LightboxImage(image: UIImage(named: "Rectangle 15")!, text: "This is a simple dummy text for viewing image.", videoURL: nil)
        let vc = LightboxController(images: [image], startIndex: 0)
        vc.pageDelegate = self
        vc.dismissalDelegate = self
        vc.dynamicBackground = true
        self.present(vc, animated: true, completion: nil)
        
    }
    
//    func userImageTapped(index: Int) {
//        let vc = Utility.getOtherUserProfileViewController()
//        self.present(vc, animated: true, completion: nil)
//    }
    
    @objc func userImageTapped() {
        let vc = Utility.getOtherUserProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func feedbackViewTapped(){
        let vc = Utility.getCommentViewController()
        isFullScreen = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func postLikeViewTapped(){
        let vc = Utility.getViewersViewController()
        vc.isForLike = true
        isFullScreen = false
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func getStikcers(){
        
        let params = ["location": userCurrentAddress]
        Utility.showOrHideLoader(shouldShow: true)
        
        API.sharedInstance.executeAPI(type: .stickers, method: .get, params: params) { (status, result, message) in
            
            DispatchQueue.main.async {
                
                if (status == .success){
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        let stickers = result["messsage"].arrayValue
                        realm.delete(realm.objects(StickersModel.self))
                        for sticker in stickers{
                            let model = StickersModel()
                            model.updateModelWithJSON(json: sticker)
                            realm.add(model)
                        }
                        Utility.showOrHideLoader(shouldShow: false)
                    }
                }
                else if (status == .failure){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        
                    }
                }
                else if (status == .authError){
                    Utility.showOrHideLoader(shouldShow: false)
                    Loaf(message, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5)) { (handler) in
                        Utility.logoutUser()
                    }
                }
            }
            
        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if (isFullScreen){
            return FullSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        else{
            return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        
    }
    
}

extension HomeViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

extension HomeViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage) {
        storyImage = image
        saveStoryMediaToFirebase(image: storyImage)
    }
}

extension HomeViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        manager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                if let area = placemark.name, let city = placemark.locality, let country = placemark.country{
                    self.userCurrentAddress = "\(area), \(city), \(country)"
                    print(self.userCurrentAddress)
                    self.getStikcers()
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == CLAuthorizationStatus.denied){
            self.getStikcers()
        }
    }
    
}

extension HomeViewController: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate{
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
