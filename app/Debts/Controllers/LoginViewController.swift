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

class LoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let groupOverviewIdentifier = "groupOverview"
    let userCellIdentifier = "ContactCell"
    
    var sectionNames = [String]()
    var peopleToDisplayInSections = [[SwiftAddressBookPerson]]()

    var contactSections = [[SwiftAddressBookPerson]]()
    var filterSections:[[SwiftAddressBookPerson]] = [[]]
    var searchMode: Bool = false {
        didSet {
            peopleToDisplayInSections = searchMode ? filterSections : contactSections
            self.contactTableView.reloadData()
        }
    }
    
    // MARK: - View Set Up
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchMode = false
        self.contactTableView.reloadData()
    }
    
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
            self.searchMode = false
            self.searchBar.hidden = false
            self.spinner.stopAnimating()
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
        return self.peopleToDisplayInSections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchMode {
            return ""
        }
        return self.sectionNames[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peopleToDisplayInSections[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        
        var user:SwiftAddressBookPerson = self.peopleToDisplayInSections[indexPath.section][indexPath.row]
        var person: User = User(person: user)
        cell.displayNameOfUser(person)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as? ContactTableViewCell {
            
            // workaround: for some reasons search messes up the cells...
            self.contactTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            cell.selected = true
            self.spinner.startAnimating()
            
            var person = User(person: self.peopleToDisplayInSections[indexPath.section][indexPath.row])
            
            GlobalVar.currentUser = person
            self.contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
            // get user details or if it does not exist, create a new on and proceed
            RequestHelper.getUserDetails(person, callback: { (userData) -> Void in
                var uid = userData.uID
                
                if count(uid) > 0 {
                    cell.selected = false
                    println("Successfully fetched uid \(uid)")
                    self.proceedWithSelectedUser(uid)
                } else {
                    RequestHelper.createUser(person, callback: { (uData) -> Void in
                        uid = uData.uID
                        cell.selected = false
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
    
    // MARK: - Search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterSections[0] = [SwiftAddressBookPerson]()
        if count(searchText) > 0 {
            for users in contactSections {
                
                let filteredUsers: [SwiftAddressBookPerson] = users.filter({ (user: SwiftAddressBookPerson) -> Bool in
                    var name = ""
                    if let first = user.firstName {
                        name += first
                    }
                    if let last = user.lastName {
                        name += last
                    }
                    let range = (name as NSString).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    return range.location != NSNotFound
                })
                
                self.filterSections[0] += filteredUsers
            }
            self.searchMode = true
        } else {
            self.searchMode = false
        }
        self.contactTableView.reloadData()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchMode = false
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        self.contactTableView.reloadData()
    }
}