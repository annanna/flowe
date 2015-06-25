//
//  UserViewController.swift
//  Debts
//
//  Created by Anna on 23.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import Foundation
import SwiftAddressBook

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var contactTableView: UITableView!
    
    let groupOverviewIdentifier = "groupOverview"
    let userCellIdentifier = "ContactCell"
    var contactSections = [[SwiftAddressBookPerson]]()
    var sectionNames = [String]()
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up loading indicator
        self.spinner.color = colors.red
        self.spinner.startAnimating()
        self.spinner.hidesWhenStopped = true
        
        // load people and display them in tableview
        AddressBookHelper.loadPeopleFromAddressBook({(people) -> Void in
            let myContacts:[SwiftAddressBookPerson] = people
            self.loadUsersInSections(myContacts)
            self.spinner.stopAnimating()
            self.contactTableView.reloadData()
        })
        
        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.contactTableView.tableFooterView = backgroundView
        self.contactTableView.backgroundColor = colors.bgGreen
        self.contactTableView.bounces = true
    }
    
    func loadUsersInSections(fetchedContacts: [SwiftAddressBookPerson]) {
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
    
    // MARK: - Table view data source & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.contactSections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionNames[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactSections[section].count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        
        let user = self.contactSections[indexPath.section][indexPath.row]
        var person: User = User(person: user)
        cell.displayNameOfUser(person)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as? ContactTableViewCell {
            self.spinner.startAnimating()
            var person: User = User(person: self.contactSections[indexPath.section][indexPath.row])
            GlobalVar.currentUser = person
            self.contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
            // get user details or if it does not exist, create a new on and proceed
            RequestHelper.getUserDetails(person, callback: { (userData) -> Void in
                var uid = userData.uID
                
                if count(uid) > 0 {
                    self.contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
                    println("Successfully fetched uid \(uid)")
                    self.proceedWithSelectedUser(uid)
                } else {
                    RequestHelper.createUser(person, callback: { (uData) -> Void in
                        uid = uData.uID
                        self.contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
                        println("Successfully created user with uid \(uid)")
                        self.proceedWithSelectedUser(uid)
                    })
                }
            })
        }
    }
    
    // MARK: - Navigation
    
    func proceedWithSelectedUser(uid: String) {
        GlobalVar.currentUid = uid
        self.spinner.stopAnimating()
        self.performSegueWithIdentifier(groupOverviewIdentifier, sender: self)
    }
}