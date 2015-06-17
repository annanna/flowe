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
    
    var users = [User]()
    var selectedUsers = [User]()
    
    let contactCellIdentifier = "ContactCell"
    let addContactIdentifier = "AddContact"
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load people and display them in tableview
        // code duplication for now with UserTableViewController, but UserTableViewController is just a temporary login replacing view
        self.loadPeopleFromAddressBook(self.loadUsersWithoutCurrentUser)
        
        self.tableView.allowsMultipleSelection = true
        var doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed:")
        self.navigationItem.rightBarButtonItem = doneBtn
        
        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
    
    func loadPeopleFromAddressBook(callback: [SwiftAddressBookPerson]->Void) {
        let status: ABAuthorizationStatus = SwiftAddressBook.authorizationStatus()
        let addressBook: SwiftAddressBook? = swiftAddressBook
        swiftAddressBook?.requestAccessWithCompletion({(success, error) -> Void in
            if success {
                if let book = addressBook {
                    if let people = book.allPeople {
                        callback(people)
                    }
                }
            } else {
                println("User denied access to addressbook")
            }
        })
    }
    
    func loadUsersWithoutCurrentUser(people: [SwiftAddressBookPerson]) {
        for person in people {
            var user = User(person: person)
            if !user.isSame(GlobalVar.currentUser) {
                self.users.append(user)
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source & Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(contactCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var person: User = self.users[indexPath.row]
        cell.textLabel?.text = "\(person.firstname) \(person.lastname)"
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    // MARK: - Navigation
    
    func donePressed(btn: UIBarButtonItem!) {
        var paths: [NSIndexPath] = tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        for path in paths {
            selectedUsers.append(self.users[path.row])
        }
        self.performSegueWithIdentifier(addContactIdentifier, sender: self)
    }
}