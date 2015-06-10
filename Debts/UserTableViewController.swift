//
//  UserTableViewController.swift
//  Debts
//
//  Temporary view for replacing login while development
//
//  Created by Anna on 12.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import Foundation
import SwiftAddressBook
import AddressBook

class UserTableViewController: UITableViewController {
    
    var myContacts = [SwiftAddressBookPerson]()
    let groupOverviewIdentifier = "groupOverview"
    let userCellIdentifier = "userCell"
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load people and display them in tableview
        self.loadPeopleFromAddressBook({(people) -> Void in
            self.myContacts = people
            self.tableView.reloadData()
        })
        
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
    
    // MARK: - Table view data source & Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myContacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var person: User = User(person: myContacts[indexPath.row])
        cell.textLabel?.text = "\(person.firstname) \(person.lastname)"
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var person: User = User(person: myContacts[indexPath.row])
        GlobalVar.currentUser = person
        
        // get user details or if it does not exist, create a new on and proceed
        RequestHelper.getUserDetails(person, callback: { (userData) -> Void in
            var uid = userData["_id"].stringValue
            
            if count(uid) > 0 {
                println("Successfully fetched uid \(uid)")
                self.proceedWithSelectedUser(uid)
            } else {
                let userPostBody = JSONHelper.createDictionaryFromUser(person)
                
                RequestHelper.createUser(userPostBody, callback: { (uData) -> Void in
                    uid = uData["_id"].stringValue
                    println("Successfully created user with uid \(uid)")
                    self.proceedWithSelectedUser(uid)
                })
            }
        })
    }
    
    // MARK: - Navigation
    
    func proceedWithSelectedUser(uid: String) {
        GlobalVar.currentUid = uid
        self.performSegueWithIdentifier(groupOverviewIdentifier, sender: self)
    }
}