//
//  ContactTableViewController.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import AddressBook

class ContactTableViewController: UITableViewController {

    let addressBook: SwiftAddressBook? = swiftAddressBook
    override func viewDidLoad() {
        super.viewDidLoad()

        let status: ABAuthorizationStatus = SwiftAddressBook.authorizationStatus()
        swiftAddressBook?.requestAccessWithCompletion({(success, error) -> Void in
            if success {
                println("success")
            } else {
                println("no success")
            }
        })
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
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveSelectedContact" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)
            }
        }
    }
}
