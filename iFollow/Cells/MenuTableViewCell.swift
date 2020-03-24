//
//  MenuTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnMinus.isEnabled = false
        btnPlus.isEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        if (lblDuration.text == "72"){
            lblDuration.text = "48"
            btnMinus.isEnabled = true
            btnPlus.isEnabled = true
        }
        else if (lblDuration.text == "48"){
            lblDuration.text = "24"
            btnMinus.isEnabled = false
            btnPlus.isEnabled = true
        }
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        if (lblDuration.text == "24"){
            lblDuration.text = "48"
            btnPlus.isEnabled = true
            btnMinus.isEnabled = true
        }
        else if (lblDuration.text == "48"){
            lblDuration.text = "72"
            btnPlus.isEnabled = false
            btnMinus.isEnabled = true
        }
    }
    
}
