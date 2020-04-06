//
//  MenuTableViewCell.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 07/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate: class {
    func switchChanged(isOn: Bool, indexPath: IndexPath)
    func durationChanged(isPlus: Bool, indexPath: IndexPath)
}

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    var delegate: MenuTableViewCellDelegate!
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        self.delegate.durationChanged(isPlus: false, indexPath: indexPath)
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        self.delegate.durationChanged(isPlus: true, indexPath: indexPath)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        self.delegate.switchChanged(isOn: sender.isOn, indexPath: indexPath)
    }
    
    
}
