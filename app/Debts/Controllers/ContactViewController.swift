//
//  ContactTableViewController.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftAddressBook

class ContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let contactCellIdentifier = "ContactCell"
    let addContactIdentifier = "AddContact"
    
    var sectionNames = [String]()
    var peopleToDisplayInSections = [[SwiftAddressBookPerson]]()
    var selectedUsers = [User]()
    
    var contactSections = [[SwiftAddressBookPerson]]()
    var filterSections:[[SwiftAddressBookPerson]] = [[]]
    var searchMode: Bool = false {
        didSet {
            peopleToDisplayInSections = searchMode ? filterSections : contactSections
            self.contactTableView.reloadData()
        }
    }
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up loading indicator
        self.spinner.color = colors.red
        self.spinner.startAnimating()
        self.spinner.hidesWhenStopped = true
        
        // load people and display them in tableview
        // code duplication for now with UserTableViewController, but UserTableViewController is just a temporary login replacing view
        AddressBookHelper.loadPeopleFromAddressBook({(people) -> Void in
            let myContacts:[SwiftAddressBookPerson] = people
            self.loadUsersInSections(myContacts)
            self.searchMode = false
            self.searchBar.hidden = false
            self.spinner.stopAnimating()
        })

        // hide empty cells
        self.contactTableView.allowsMultipleSelection = true
        var backgroundView = UIView(frame: CGRectZero)
        self.contactTableView.tableFooterView = backgroundView
        self.contactTableView.backgroundColor = colors.bgGreen
    }
    
    func loadUsersInSections(fetchedContacts: [SwiftAddressBookPerson]) {
        
        var people = fetchedContacts //mutable copy
        people.sort({$0.firstName?.uppercaseString < $1.firstName?.uppercaseString})
        
        var sectionLetter = ""
        var sectionIndex = -1
        
        self.contactSections = []
        self.sectionNames = []
        
        for contact in people {
            if contact.phoneNumber == GlobalVar.currentUser.phoneNumber {
                // it's me so don't show in list
                println("its me")
            } else {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(contactCellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        var person: SwiftAddressBookPerson = self.peopleToDisplayInSections[indexPath.section][indexPath.row]
        cell.displayNameOfUser(person)
        
        for user in self.selectedUsers {
            if user.phoneNumber == person.phoneNumber {
                cell.selectedInMultipleMode = true
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // to handle select and deselect-event in one method, deselect here and handle deselection myself
        self.contactTableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
        // workaround: for some reasons search messes up the cells...
        //self.contactTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        cell.selectedInMultipleMode = !cell.selectedInMultipleMode
        let selectedPerson = self.peopleToDisplayInSections[indexPath.section][indexPath.row]
        RequestHelper.getUserDetails(selectedPerson.asDictionary(), byId: false) { (user) -> Void in
            if cell.selectedInMultipleMode {
                self.selectedUsers.append(user)
            } else {
                for (idx, selUser) in enumerate(self.selectedUsers) {
                    if selUser.isSame(user) {
                        self.selectedUsers.removeAtIndex(idx);
                    }
                }
            }
        }
    }
    
    // MARK: - Search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterSections[0] = [SwiftAddressBookPerson]()
        if count(searchText) > 0 {
            for users in contactSections {
                
                let filteredUsers: [SwiftAddressBookPerson] = users.filter({ (user: SwiftAddressBookPerson) -> Bool in
                    var name = "\(user.firstname) \(user.lastname)"
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