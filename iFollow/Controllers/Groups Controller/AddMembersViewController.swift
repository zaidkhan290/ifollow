//
//  AddMembersViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 15/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class AddMembersViewController: UIViewController {

    @IBOutlet weak var membersView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var membersTableView: UITableView!
    
    var selectedIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        membersView.roundTopCorners(radius: 30)
        searchView.dropShadow(color: .white)
        searchView.layer.cornerRadius = 25
        Utility.setTextFieldPlaceholder(textField: txtFieldSearch, placeholder: "Search", color: Theme.searchFieldColor)
        
        let cellNib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        membersTableView.register(cellNib, forCellReuseIdentifier: "FriendsTableViewCell")
        membersTableView.rowHeight = 60
        
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func btnAddTapped(_ sender: UIButton) {
        self.view.makeToast("Members Added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.goBack()
        }
    }
    
}

extension AddMembersViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        
        cell.btnSend.isHidden = true
        cell.selectImage.isHidden = false
        
        if (selectedIndex.contains(indexPath.row)){
            cell.selectImage.image = UIImage(named: "select")
        }
        else{
            cell.selectImage.image = UIImage(named: "unselect")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !(selectedIndex.contains(indexPath.row)){
            selectedIndex.append(indexPath.row)
        }
        else{
            let indexToRemove = selectedIndex.firstIndex(of: indexPath.row)!
            selectedIndex.remove(at: indexToRemove)
        }
        self.membersTableView.reloadData()
        
    }
    
}
