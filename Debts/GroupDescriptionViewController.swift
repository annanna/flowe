//
//  GroupDescriptionViewController.swift
//  Debts
//
//  Created by Anna on 22.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class GroupDescriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var group:Group? {
        didSet {
            self.configureView()
        }
    }
    let transferCell = "transferCell"
    
    func configureView() {
        if let gr: Group = self.group {
            if let groupName = self.groupName {
                groupName.text = gr.name

            }
            if let userLabel = self.userLabel {
                userLabel.text = gr.getUsers()
            }
            if let sumLabel = self.sumLabel {
                sumLabel.text = String(format: "%.2f€", gr.total)
                if gr.total < 0 {
                    sumLabel.textColor = UIColor.redColor()
                } else {
                    sumLabel.textColor = UIColor.greenColor()
                }
            }
        }
        
      /*  var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()*/
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group!.transfers.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(transferCell, forIndexPath: indexPath) as! UITableViewCell
        
        let transfer = group!.transfers[indexPath.row]
        cell.textLabel?.text = String(format: "\(transfer.userPayed.getName()) hat %.2f€ für \(transfer.name) bezahlt", transfer.moneyPayed)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
    }

}
