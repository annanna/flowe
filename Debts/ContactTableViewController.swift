//
//  ContactTableViewController.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftAddressBook
import AddressBook

class ContactTableViewController: UITableViewController {

    let addressBook: SwiftAddressBook? = swiftAddressBook
    var selectedUsers:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true

        let status: ABAuthorizationStatus = SwiftAddressBook.authorizationStatus()
        swiftAddressBook?.requestAccessWithCompletion({(success, error) -> Void in
            if success {
                println("success")
            } else {
                println("no success")
            }
        })
        
        var doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed:")
        self.navigationItem.rightBarButtonItem = doneBtn
        
        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBook!.allPeople!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! UITableViewCell
        var person: SwiftAddressBookPerson = addressBook!.allPeople![indexPath.row]
        cell.textLabel?.text = "\(person.firstName!) \(person.lastName!)"
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    func donePressed(btn: UIBarButtonItem!) {
        var paths: [NSIndexPath] = tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        for path in paths {
            var selectedContact: SwiftAddressBookPerson = addressBook!.allPeople![path.row]
            var numbers = selectedContact.phoneNumbers!
            var num = numbers[0].value
            var user = User(phone: num, first: selectedContact.firstName!, last: selectedContact.lastName!)
            if selectedContact.hasImageData() {
                user.img = selectedContact.image
            }
            selectedUsers.append(user)
        }
        self.performSegueWithIdentifier("AddContact", sender: self)
    }
}
