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
    
    var selectedUsers = [User]()
    var contactSections = [[User]]()
    var sectionNames = [String]()
    
    let contactCellIdentifier = "ContactCell"
    let addContactIdentifier = "AddContact"
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load people and display them in tableview
        // code duplication for now with UserTableViewController, but UserTableViewController is just a temporary login replacing view
        self.loadPeopleFromAddressBook({(people) -> Void in
            let myContacts:[SwiftAddressBookPerson] = people
            self.loadUsersInSections(myContacts)
            self.tableView.reloadData()
        })
        
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
    
    func loadUsersInSections(fetchedContacts: [SwiftAddressBookPerson]) {
        
        var people = fetchedContacts //mutable copy
        people.sort({$0.firstName?.uppercaseString < $1.firstName?.uppercaseString})
        
        var sectionLetter = ""
        var sectionIndex = -1
        
        self.contactSections = []
        self.sectionNames = []
        
        
        for person in people {
            var user = User(person: person)
            if !user.isSame(GlobalVar.currentUser) {
                let nameCount = count(user.firstname)
                if nameCount > 0 {
                    let firstLetter = String(Array(user.firstname)[0])
                    
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
                self.contactSections[sectionIndex].append(user)
            }
        }
    }
    
    
    // MARK: - Table view data source & Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.contactSections.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionNames[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactSections[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(contactCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var person: User = self.contactSections[indexPath.section][indexPath.row]
        
        let labelText = "\(person.firstname) \(person.lastname)"
        let highlightRange = (labelText as NSString).rangeOfString(person.lastname)
        // create attributed string so that lastname is displayed in bold
        let attributedString = NSMutableAttributedString(string: labelText, attributes:[NSFontAttributeName : UIFont.systemFontOfSize(17.0)])
        attributedString.setAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17)], range: highlightRange)
        
        cell.textLabel?.attributedText = attributedString
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
            selectedUsers.append(self.contactSections[path.section][path.row])
        }
        self.performSegueWithIdentifier(addContactIdentifier, sender: self)
    }
}