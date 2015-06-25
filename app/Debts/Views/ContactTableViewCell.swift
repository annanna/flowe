//
//  ContactTableViewCell.swift
//  Debts
//
//  Created by Anna on 23.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var peopleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.backgroundColor = colors.green
        self.peopleLabel.textColor = UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // TODO: why is label text removed between first and second call?
//        if selected {
//            println("Label text: \(self.peopleLabel.text!)")
//        } else {
//
//        }

    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        // workaround for selection status - would be better to select instead of highlighting
        if highlighted {
            self.contentView.backgroundColor = colors.red
        } else {
            self.contentView.backgroundColor = colors.green
        }
    }
    
    func displayNameOfUser(person: User) {
        
        let labelText = "\(person.firstname) \(person.lastname)"
        let highlightRange = (labelText as NSString).rangeOfString(person.firstname)
        
        // create attributed string so that lastname is displayed in bold
        let attributedString = NSMutableAttributedString(string: labelText, attributes:[NSFontAttributeName : UIFont.systemFontOfSize(17.0)])
        attributedString.setAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17)], range: highlightRange)
        
        self.peopleLabel.attributedText = attributedString
        self.peopleLabel.textColor = UIColor.darkGrayColor()
    }
}
