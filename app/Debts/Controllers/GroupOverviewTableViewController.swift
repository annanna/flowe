//
//  GroupOverviewTableViewController.swift
//  Debts
//
//  Created by Anna on 22.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class GroupOverviewTableViewController: UITableViewController {
    
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var groups = [Group]()
    let groupDetailIdentifier = "groupDetail"
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let loginVC = appDelegate.storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        appDelegate.window?.rootViewController?.presentViewController(loginVC, animated: false, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        self.getGroupsOfUser()
    }
    
    func getGroupsOfUser() {
        RequestHelper.getGroups { (groups) -> Void in
            self.groups = groups
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source & Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GroupOverviewTableViewCell
        let group = groups[indexPath.row] as Group
        cell.titleLabel.text = group.name
        if let pView = cell.people as? PeopleView {
            pView.setPeopleInView(group.users)
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == groupDetailIdentifier {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let group:Group = groups[indexPath.row]
                if let vc = segue.destinationViewController as? GroupDetailViewController {
                    vc.groupId = group.gID
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelToGroupOverview(segue: UIStoryboardSegue) {}
    @IBAction func saveNewGroup(segue: UIStoryboardSegue) {
        if let addGroupVC = segue.sourceViewController as? AddGroupTableViewController {
            if let name =  addGroupVC.groupName {
                var users = addGroupVC.selectedContacts
                users.append(GlobalVar.currentUser)
                RequestHelper.postGroup(name.text!, users: users, callback: { (groupData) -> Void in
                    self.addNewGroup(groupData)
                })
            }
        }
    }
    
    func addNewGroup(group: Group) {
        groups.insert(group, atIndex: 0)
        let path = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
}