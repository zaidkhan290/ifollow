//
//  OptionsViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 08/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var optionTableView: UITableView!
    var options = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionTableView.rowHeight = 50
        options = ["Block", "Report", "Copy User Url", "Private Talk"]
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsTableViewCell", for: indexPath) as! OptionsTableViewCell
        cell.lblTitle.text = options[indexPath.row]
        return cell
    }
}
