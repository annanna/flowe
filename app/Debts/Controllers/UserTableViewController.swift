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
    
    let groupOverviewIdentifier = "groupOverview"
    let userCellIdentifier = "userCell"
    var contactSections = [[SwiftAddressBookPerson]]()
    var sectionNames = [String]()
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load people and display them in tableview
        self.loadPeopleFromAddressBook({(people) -> Void in
            let myContacts:[SwiftAddressBookPerson] = people
            self.createSectionsArray(myContacts)
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
        return self.contactSections.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionNames[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     //   return self.myContacts.count
        return self.contactSections[section].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let user = self.contactSections[indexPath.section][indexPath.row]
        var person: User = User(person: user)
        //var person: User = User(person: myContacts[indexPath.row])
        
        let labelText = "\(person.firstname) \(person.lastname)"
        let highlightRange = (labelText as NSString).rangeOfString(person.firstname)
        // create attributed string so that lastname is displayed in bold
        let attributedString = NSMutableAttributedString(string: labelText, attributes:[NSFontAttributeName : UIFont.systemFontOfSize(17.0)])
        attributedString.setAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17)], range: highlightRange)
        
        cell.textLabel?.attributedText = attributedString
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var person: User = User(person: self.contactSections[indexPath.section][indexPath.row])
        GlobalVar.currentUser = person
        
        // get user details or if it does not exist, create a new on and proceed
        RequestHelper.getUserDetails(person, callback: { (userData) -> Void in
            var uid = userData.uID
            
            if count(uid) > 0 {
                println("Successfully fetched uid \(uid)")
                self.proceedWithSelectedUser(uid)
            } else {
                RequestHelper.createUser(person, callback: { (uData) -> Void in
                    uid = uData.uID
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
    
    func sortNames(s1: String, s2: String) -> Bool {
        return s1 < s2
    }
    
    func createSectionsArray(fetchedContacts: [SwiftAddressBookPerson]) {
        var myContacts = fetchedContacts //mutable copy
        myContacts.sort({$0.firstName?.uppercaseString < $1.firstName?.uppercaseString})
        
        var sectionLetter = ""
        var sectionIndex = -1
        
        self.contactSections = []
        self.sectionNames = []
        
        for contact in myContacts {
            if let first = contact.firstName {
                let firstLetter = String(Array(first)[0])
                
                if sectionLetter != firstLetter {
                    sectionNames.append(firstLetter)
                    contactSections.append([])
                    sectionIndex++
                    sectionLetter = firstLetter
                }
            } else {
                let alternateLetter = "#"
                if let index = find(sectionNames, alternateLetter) {
                    sectionIndex = index
                } else{
                    sectionNames.append(alternateLetter)
                    contactSections.append([])
                    sectionIndex++
                    sectionLetter = alternateLetter
                }
            }
            contactSections[sectionIndex].append(contact)
        }
    }
}