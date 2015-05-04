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

        // Configure the view for the selected state
    }
    
    var btnX:CGFloat = 0;
    let btnY:CGFloat = 0;
    let btnSize:CGFloat = 40;
    
    func loadItem(title: String, users: [User]) {
        titleLabel.text = title
        for user in users {
            var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), user: user)
            people.addSubview(btn)
            btnX += btnSize + btnSize/2
        }
    }

}
