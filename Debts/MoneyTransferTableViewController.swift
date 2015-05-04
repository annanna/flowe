//
//  MoneyTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 04.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class MoneyTransferTableViewController: UITableViewController {
    
    var selectedUsers:[User] = []
    var mode = ""
    var amount: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(amount) €"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return selectedUsers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("balanceCell", forIndexPath: indexPath) as! UITableViewCell
        var person = selectedUsers[indexPath.row]
        cell.textLabel?.text = "\(person.firstname) \(person.lastname)"

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if segue.identifier == "SaveSelectedContacts" {
            var users: [User] = []
            var paths: [NSIndexPath] = tableView.indexPathsForSelectedRows() as! [NSIndexPath]
            for path in paths {
                var selectedContact: SwiftAddressBookPerson = addressBook!.allPeople![path.row]
                var user = User(first: selectedContact.firstName!, last: selectedContact.lastName!)
                if selectedContact.hasImageData() {
                    user.img = selectedContact.image
                }
                users.append(user)
            }
            selectedUsers = users
        }*/
    }

}
