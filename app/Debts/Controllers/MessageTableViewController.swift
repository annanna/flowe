//
//  MessageTableViewController.swift
//  Debts
//
//  Created by Anna on 23.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController {
    
    let cellIdentifier = "messageCell"
    var messages:[Message] = [Message]()
    
    override func viewWillAppear(animated: Bool) {
        RequestHelper.getMessages {
            (messageData: [Message]) -> Void in
            self.messages = messageData
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 
        let message = self.messages[indexPath.row]
        cell.textLabel?.text = "\(message.sender.firstname)\(message.message)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = self.messages[indexPath.row]
        // go to relevant detail view
        
        // delete from list and database
//        self.messages.removeAtIndex(indexPath.row)
//        self.tableView.reloadData()
        
//        RequestHelper.deleteMessage(selectedMessage.mId)
        
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
