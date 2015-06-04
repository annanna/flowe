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
   @IBAction func addContacts(segue: UIStoryboardSegue) {
      if let contactVC = segue.sourceViewController as? ContactTableViewController {
         self.selectedContacts = contactVC.selectedUsers
         self.showMembersInView()
      }
   }
   
   var selectedContacts:[User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
   func showMembersInView() {
      if let members = self.memberView as? PeopleView {
         members.setPeopleInView(selectedContacts)
      }
   }
}
