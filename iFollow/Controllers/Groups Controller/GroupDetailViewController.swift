//
//  GroupDetailViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 13/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import AppImageViewer

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
    
    var mediaImages = [String]()
    var imagePicker = UIImagePickerController()
    var isGroupNameEditable = false
    
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
        
        txtFieldGroupName.isUserInteractionEnabled = isGroupNameEditable
        txtFieldGroupName.delegate = self
        
        mediaImages = ["Rectangle 117", "Rectangle 118", "Rectangle 121", "Rectangle 122", "Rectangle 117", "Rectangle 118", "Rectangle 121", "Rectangle 122"]
        
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
    }
    
    @IBAction func btnAddMembersTapped(_ sender: UIButton) {
    }
    
    func openImagePicker(){
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
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
        return mediaImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCollectionViewCell
        cell.mediaImage.image = UIImage(named: mediaImages[indexPath.row])
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
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
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

extension GroupDetailViewController: AppImageViewerDelegate{
    
}
