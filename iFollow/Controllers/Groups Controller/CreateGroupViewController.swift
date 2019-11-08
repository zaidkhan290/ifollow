//
//  CreateGroupViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomView.layer.cornerRadius = 10
        bottomView.dropShadow(color: .white)
        groupImage.roundBottomCorners(radius: 20)
        notificationSwitch.isOn = false
        notificationSwitch.tintColor = Theme.profileLabelsYellowColor
        notificationSwitch.onTintColor = Theme.profileLabelsYellowColor
        imagePicker.delegate = self
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnCameraTapped(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func btnEditTapped(_ sender: UIButton) {
        
    }
    
    func openImagePicker(){
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

extension CreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
