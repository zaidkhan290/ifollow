//
//  GroupDetailViewController.swift
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
import Firebase

class GroupDetailViewController: UIViewController {

    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var txtFieldGroupName: UITextField!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var mediaAndMembersView: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mediaAndMemberViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deactivateGroupView: UIView!
    
    var mediaArray = [ChatMediaModel]()
    var imagePicker = UIImagePickerController()
    var isGroupNameEditable = false
    var groupChatId = ""
    var groupMediaRef = rootRef
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupImage.roundBottomCorners(radius: 20)
        groupImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupImageTapped)))
        
        mediaAndMembersView.layer.cornerRadius = 10
        mediaAndMembersView.dropShadow(color: .white)
        deactivateGroupView.layer.cornerRadius = 10
        deactivateGroupView.dropShadow(color: .white)
        deactivateGroupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deactivateGroupTapped)))
        
        notificationSwitch.isOn = false
        notificationSwitch.tintColor = Theme.profileLabelsYellowColor
        notificationSwitch.onTintColor = Theme.profileLabelsYellowColor
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        txtFieldGroupName.delegate = self
        
        let mediaCellNib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        mediaCollectionView.register(mediaCellNib, forCellWithReuseIdentifier: "MediaCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.mediaCollectionView.collectionViewLayout = layout
        self.mediaCollectionView.showsHorizontalScrollIndicator = false
        
        let memberCellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        membersTableView.register(memberCellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        membersTableView.rowHeight = 60
        membersTableView.isScrollEnabled = false
        
        groupMediaRef = groupMediaRef.child("GroupMedia").child(groupChatId)
        groupMediaRef.observe(.childAdded) { (snapshot) in
            let mediaType = snapshot.childSnapshot(forPath: "mediaType").value as! Int
            let mediaUrl = snapshot.childSnapshot(forPath: "mediaUrl").value as! String
            let mediaTimestamp = snapshot.childSnapshot(forPath: "mediaTimestamp").value as! Double
            
            let model = ChatMediaModel()
            model.mediaUrl = mediaUrl
            model.mediaType = mediaType
            model.mediaTimestamp = mediaTimestamp
            self.mediaArray.append(model)
            self.mediaCollectionView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            let membersTableViewHeight = self.membersTableView.contentSize.height
            self.mediaAndMemberViewHeightConstraint.constant = membersTableViewHeight + 220
            self.mainViewHeightConstraint.constant = self.mediaAndMemberViewHeightConstraint.constant + 390
            self.view.updateConstraintsIfNeeded()
            self.view.layoutSubviews()
            
        }
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnEditTapped(_ sender: UIButton) {
        isGroupNameEditable = !isGroupNameEditable
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        if isGroupNameEditable{
            txtFieldGroupName.becomeFirstResponder()
        }
    }
    
    @IBAction func btnAllMediaTapped(_ sender: UIButton) {
        let vc = Utility.getMediaViewController()
        vc.mediaArray = mediaArray
        self.pushToVC(vc: vc)
    }
    
    @IBAction func btnAddMembersTapped(_ sender: UIButton) {
    }
    
    func openImagePicker(){
        
        let alertVC = UIAlertController(title: "Select Action", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func groupImageTapped(){
        openImagePicker()
    }
    
    @objc func deactivateGroupTapped(){
        
        let alertVC = UIAlertController(title: "Leave from Group", message: "are you sure you want to leave this group?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes Leave", style: .destructive) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        alertVC.addAction(yesAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}

extension GroupDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
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

extension GroupDetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.btnSend.isHidden = true
        cell.btnOption.isHidden = false
        cell.lblUsername.textColor = Theme.memberNameColor
        cell.lblUsername.text = "Emma Watson"
        cell.lblLastSeen.text = "Sed ut perpicaiatics unde omnis iste"
        return cell
    }
    
}

extension GroupDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            groupImage.clipsToBounds = true
            groupImage.contentMode = .scaleAspectFill
            groupImage.image = image
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension GroupDetailViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtFieldGroupName.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        isGroupNameEditable = false
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        txtFieldGroupName.text = txtFieldGroupName.text == "" ? "Family Group" : txtFieldGroupName.text!
        
    }
    
}

extension GroupDetailViewController: DTPhotoViewerControllerDelegate{
    
}
