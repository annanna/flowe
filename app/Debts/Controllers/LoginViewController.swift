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

extension SwiftAddressBookPerson {
    func asDictionary() -> [String: String] {
        return [
            "phone": self.phoneNumber,
            "firstname": self.firstname,
            "lastname": self.lastname
        ]
    }
    
    var firstname: String {
        get {
            if let first = self.firstName {
                return first
            }
            return ""
        }
    }
    var lastname: String {
        get {
            if let last = self.lastName {
                return last
            }
            return ""
        }
    }
    var phoneNumber: String {
        get {
            if let numbers = self.phoneNumbers {
                if numbers.count > 0 {
                    return numbers[0].value
                }
            }
            return ""
        }
    }
}

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
    override func prefersStatusBarHidden() -> Bool {
        return true;
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
        let backgroundView = UIView(frame: CGRectZero)
        self.contactTableView.tableFooterView = backgroundView
        self.contactTableView.backgroundColor = colors.bgGreen
        self.contactTableView.bounces = true
    }
    
    func loadUsersInSections(fetchedContacts: [SwiftAddressBookPerson]) {
        var myContacts = fetchedContacts //mutable copy
        myContacts.sortInPlace({$0.firstName?.uppercaseString < $1.firstName?.uppercaseString})
        
        var sectionLetter = ""
        var sectionIndex = -1
        
        self.contactSections = []
        self.sectionNames = []
        
        for contact in myContacts {
            if let first = contact.firstName {
                let firstLetter = String(Array(arrayLiteral: first)[0])
                
                if sectionLetter != firstLetter {
                    sectionNames.append(firstLetter)
                    contactSections.append([])
                    sectionIndex++
                    sectionLetter = firstLetter
                }
            } else {
                let alternateLetter = "#"
                if let index = sectionNames.indexOf(alternateLetter) {
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
        
        let user:SwiftAddressBookPerson = self.peopleToDisplayInSections[indexPath.section][indexPath.row]
        cell.displayNameOfUser(user)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.dequeueReusableCellWithIdentifier(userCellIdentifier, forIndexPath: indexPath) as? ContactTableViewCell {
            
            // workaround: for some reasons search messes up the cells...
            self.contactTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            cell.selected = true
            self.spinner.startAnimating()
            
            let person:SwiftAddressBookPerson = self.peopleToDisplayInSections[indexPath.section][indexPath.row]
            RequestHelper.getUserDetails(person.asDictionary(), byId: false, callback: { (user) -> Void in
                GlobalVar.currentUser = user
                self.contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.proceedWithSelectedUser(user.uID)
                
            })
        }
    }
    
    // MARK: - Navigation
    
    func proceedWithSelectedUser(uid: String) {
        GlobalVar.currentUid = uid
        GlobalVar.currentUser.uID = uid
        self.spinner.stopAnimating()
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = appDelegate.tabBarController
    }    
    
    // MARK: - Search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterSections[0] = [SwiftAddressBookPerson]()
        if searchText.characters.count > 0 {
            for users in contactSections {
                
                let filteredUsers: [SwiftAddressBookPerson] = users.filter({ (user: SwiftAddressBookPerson) -> Bool in
                    let name = "\(user.firstname) \(user.lastname)"
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