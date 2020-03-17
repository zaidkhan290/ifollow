//
//  SignupDetail2ViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import Loaf

class SignupDetail2ViewController: UIViewController {

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTableView: UITableView!
    
    var textFieldPlaceholders = [String]()
    var textFieldImages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailView.roundTopCorners(radius: 30)
        
        let imageCellNib = UINib(nibName: "EditProfileImageTableViewCell", bundle: nil)
        let txtFieldCellNib = UINib(nibName: "EditProfileTextFieldsTableViewCell", bundle: nil)
        let doneButtonCellNib = UINib(nibName: "EditProfileSaveButtonTableViewCell", bundle: nil)
        
        detailTableView.register(imageCellNib, forCellReuseIdentifier: "EditProfileImageTableViewCell")
        detailTableView.register(txtFieldCellNib, forCellReuseIdentifier: "EditProfileTextFieldsTableViewCell")
        detailTableView.register(doneButtonCellNib, forCellReuseIdentifier: "EditProfileSaveButtonTableViewCell")
        
        textFieldPlaceholders = ["", "Short Bio", "Hobby", "Country", "Zip Code", "City"]
        textFieldImages = ["", "username-1", "hobby", "country", "zip-code", "city"]
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
}

extension SignupDetail2ViewController: UITableViewDataSource, UITableViewDelegate, EditProfileDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImageTableViewCell", for: indexPath) as! EditProfileImageTableViewCell
            cell.btnCamera.isHidden = true
            cell.userImage.isHidden = true
            cell.doneIcon.isHidden = false
            return cell
        }
        else if (indexPath.row == 6){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileSaveButtonTableViewCell", for: indexPath) as! EditProfileSaveButtonTableViewCell
            // cell.btnDone.backgroundColor = .clear
            cell.btnDone.setTitle("Next", for: .normal)
            cell.delegate = self
            //   cell.btnDone.setImage(UIImage(named: "nextButton"), for: .normal)
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTextFieldsTableViewCell", for: indexPath) as! EditProfileTextFieldsTableViewCell
            Utility.setTextFieldPlaceholder(textField: cell.txtField, placeholder: textFieldPlaceholders[indexPath.row], color: Theme.editProfileTextFieldColor)
            cell.icon.image = UIImage(named: textFieldImages[indexPath.row])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0){
            return 220
        }
        else if (indexPath.row == 6){
            return 130
        }
        return 60
    }
    
    func btnDoneTapped() {
        let vc = Utility.getTabBarViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
}
