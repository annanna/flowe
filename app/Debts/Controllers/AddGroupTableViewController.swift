//
//  AddGroupTableViewController.swift
//  Debts
//
//  Created by Anna on 08.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class AddGroupTableViewController: UITableViewController {
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var memberView: UIView!
    
    var selectedContacts = [User]()
    let contactIdentifier = "selectContacts"
    
    @IBAction func addContacts(segue: UIStoryboardSegue) {
        if let contactVC = segue.sourceViewController as? ContactViewController {
            self.selectedContacts = contactVC.selectedUsers
            
            if let members = self.memberView as? PeopleView {
                members.setPeopleInView(selectedContacts)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == contactIdentifier {
            if let contactVC = segue.destinationViewController as? ContactViewController {
                    contactVC.selectedUsers = self.selectedContacts
            }
        }
    }
}
