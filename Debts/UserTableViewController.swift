//
//  UserTableViewController.swift
//  Debts
//
//  Created by Anna on 12.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftAddressBook
import AddressBook

class UserTableViewController: UITableViewController {

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
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UITableViewCell
        var person: SwiftAddressBookPerson = addressBook!.allPeople![indexPath.row]
        cell.textLabel?.text = "\(person.firstName!) \(person.lastName!)"
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
