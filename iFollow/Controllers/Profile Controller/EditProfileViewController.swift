//
//  EditProfileViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editProfileTableView: UITableView!
    
    var textFieldPlaceholders = [String]()
    var textFieldImages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editView.roundTopCorners(radius: 30)
        
        let imageCellNib = UINib(nibName: "EditProfileImageTableViewCell", bundle: nil)
        let txtFieldCellNib = UINib(nibName: "EditProfileTextFieldsTableViewCell", bundle: nil)
        let genderCellNib = UINib(nibName: "EditProfileGenderTableViewCell", bundle: nil)
        let doneButtonCellNib = UINib(nibName: "EditProfileSaveButtonTableViewCell", bundle: nil)
        
        editProfileTableView.register(imageCellNib, forCellReuseIdentifier: "EditProfileImageTableViewCell")
        editProfileTableView.register(txtFieldCellNib, forCellReuseIdentifier: "EditProfileTextFieldsTableViewCell")
        editProfileTableView.register(genderCellNib, forCellReuseIdentifier: "EditProfileGenderTableViewCell")
        editProfileTableView.register(doneButtonCellNib, forCellReuseIdentifier: "EditProfileSaveButtonTableViewCell")
        
        textFieldPlaceholders = ["", "First Name", "Last Name", "mm/dd/yy", "Username", "", "Short Bio", "Hobby", "Country", "Zip Code", "City"]
        textFieldImages = ["", "username-1", "username-1", "calendar", "username-1", "", "username-1", "hobby", "country", "zip-code", "city"]
    }
   
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImageTableViewCell", for: indexPath) as! EditProfileImageTableViewCell
            return cell
        }
        else if (indexPath.row == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileGenderTableViewCell", for: indexPath) as! EditProfileGenderTableViewCell
            return cell
        }
        else if (indexPath.row == 11){
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileSaveButtonTableViewCell", for: indexPath) as! EditProfileSaveButtonTableViewCell
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
            return 150
        }
        else if (indexPath.row == 5){
            return 70
        }
        else if (indexPath.row == 11){
            return 80
        }
        return 60
    }
    
}
