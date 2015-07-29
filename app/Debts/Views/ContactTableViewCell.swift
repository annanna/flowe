//
//  ContactTableViewCell.swift
//  Debts
//
//  Created by Anna on 23.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftAddressBook

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var peopleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
        self.contentView.backgroundColor = colors.green
        self.peopleLabel.textColor = UIColor.whiteColor()
    }
    
    override var selected : Bool {
        didSet {
            
            self.backgroundColor = selected ? colors.red : colors.green
        }
    }
    
    var selectedInMultipleMode : Bool = false {
        didSet {
            self.backgroundColor = selectedInMultipleMode ? colors.bgGreen : colors.green
            self.accessoryType = selectedInMultipleMode ? .Checkmark : .None
        }
    }
    
    func displayNameOfUser(addressBookPerson: SwiftAddressBookPerson) {        
        let labelText = "\(addressBookPerson.firstname) \(addressBookPerson.lastname)"
        let highlightRange = (labelText as NSString).rangeOfString(addressBookPerson.firstname)
        
        // create attributed string so that lastname is displayed in bold
        let attributedString = NSMutableAttributedString(string: labelText, attributes:[NSFontAttributeName : UIFont.systemFontOfSize(17.0)])
        attributedString.setAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17)], range: highlightRange)
        
        self.peopleLabel.attributedText = attributedString
        self.peopleLabel.textColor = UIColor.darkGrayColor()
    }
}
