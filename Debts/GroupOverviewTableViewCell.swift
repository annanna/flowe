//
//  GroupOverviewTableViewCell.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class GroupOverviewTableViewCell: UITableViewCell {
    
    @IBOutlet var people: UIView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.titleLabel.textColor = UIColor.darkGrayColor()
        // Configure the view for the selected state
    }
}
