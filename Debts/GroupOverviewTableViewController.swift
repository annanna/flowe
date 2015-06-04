//
//  GroupOverviewTableViewController.swift
//  Debts
//
//  Created by Anna on 22.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class GroupOverviewTableViewController: UITableViewController {
    
    var groups:[Group] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func cancelToGroupOverview(segue: UIStoryboardSegue) {}
    @IBAction func saveNewGroup(segue: UIStoryboardSegue) {
      if let addGroupVC = segue.sourceViewController as? AddGroupTableViewController {
         if let name =  addGroupVC.groupName {
            var newGroup = Group(name: name.text, users: addGroupVC.selectedContacts, creator: GlobalVar.currentUser)
            self.addNewGroup(newGroup)
         }
      }
   }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        self.groups = appDelegate.groups.getGroupsOfUser(GlobalVar.currentUser)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        return groups.count
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

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "groupDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let group = groups[indexPath.row] as Group
                let vc = segue.destinationViewController as! GroupDescriptionViewController
                vc.group = group
            }
        }
    }
   
   // MARK: - Actions
   
   func addNewGroup(group: Group) {
        groups.append(group)
        appDelegate.groups.addGroup(group)
        var rowNum:Int = 1
        if groups.count > 0 {
            rowNum = groups.count-1
        }
        let indexPath = NSIndexPath(forRow: rowNum, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
   }
}
