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
      if let members = self.memberView {
         for contact in selectedContacts {
            var btn = self.createBtn(contact)
            members.addSubview(btn)
         }
      }
   }
   
   // MARK: PeopleButtons
   
   var btnX:CGFloat = 20;
   let btnY:CGFloat = 15;
   let btnSize:CGFloat = 40;
   func createBtn(user: User) -> PeopleButton {
      var rect:CGRect = CGRectMake(btnX, btnY, btnSize, btnSize)
      var btn = PeopleButton(frame: rect, user: user)
      btnX += btnSize + btnSize/2
      return btn
   }
}
