//
//  GroupDescriptionViewController.swift
//  Debts
//
//  Created by Anna on 22.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class GroupDescriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var sumBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let addTransferIdentifier = "addTransfer"
    let transferDetailIdentifier = "showTransfer"
    let transferCell = "transferCell"
    let financeIdentifier = "showFinance"
    
    var group:Group?
    var transfers = [MoneyTransfer]()
    var groupId: String = ""
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGroupDetails()
    }
    
    func getGroupDetails() {
        RequestHelper.getGroupDetails(self.groupId, callback: { (groupData) -> Void in
            self.group = groupData
            self.transfers = groupData.transfers
            
            self.configureView()
            self.tableView.reloadData()
        })
    }
    
    func configureView() {
        self.title = group!.name
        if let peopleV = self.peopleView as? PeopleView {
            peopleV.setPeopleInView(group!.users)
        }
        
        updateSumLabel()
        
        // auto height of cells
        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()

    }
    
    // MARK: - Table view data source & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transfers.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(transferCell, forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = generateTransferConclusion(self.transfers[indexPath.row])
        return cell
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == transferDetailIdentifier {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                if let transfer = group?.transfers[indexPath.row] as MoneyTransfer! {
                    let vc = segue.destinationViewController as! TransferTableViewController
                    vc.transferId = transfer.tID
                    vc.group = group
                }
            }
        } else if segue.identifier == addTransferIdentifier {
            // TransferTableViewController is embedded in UINavigationController because of modal presentation
            let nav = segue.destinationViewController as! UINavigationController
            let transferVC = nav.topViewController as! TransferTableViewController
            transferVC.group = group
        }  else if segue.identifier == financeIdentifier {
            if let financeVC = segue.destinationViewController as? FinanceViewController {
                financeVC.total = self.group!.total
                financeVC.groupId = self.group!.gID
            }
        }
    }

    // MARK: Actions
    
    @IBAction func cancelToGroupDescription(segue: UIStoryboardSegue) {}
    @IBAction func saveNewTransfer(segue: UIStoryboardSegue) {
        if let addTransferVC = segue.sourceViewController as? TransferTableViewController {
            if let t = addTransferVC.transfer {
                RequestHelper.postTransfer(self.groupId, transfer: t, callback: { (transfer) -> Void in
                    self.addNewTransfer(transfer)
                })
            }
        }
    }
    
    func addNewTransfer(transfer: MoneyTransfer) {
        self.transfers.insert(transfer, atIndex: 0)
        var path = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Bottom)
        self.group?.updateTotal(transfer)
        self.updateSumLabel()
    }
    
    func updateSumLabel() {
        if let sum = self.sumBtn {
            let total = group!.total
            sum.setTitle(total.toMoneyString(), forState: UIControlState.Normal)
            if total < 0 {
                sum.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            } else {
                sum.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
            }
        }
    }
    
    func generateTransferConclusion(transfer: MoneyTransfer) -> String {
        var firstUser = transfer.payed[0].user
        var label = firstUser.firstname
        var verb = " hat "
        if firstUser.uID == GlobalVar.currentUid {
            label = "Du"
            verb = " hast "
        }
        var usersLeft = transfer.payed.count-1
        var count = 1

        
        var joiner = ""
        if usersLeft > 0 {
            joiner = ", "
            verb = " haben "
        
            for (user, amount) in transfer.payed[1...usersLeft] {
                if count == usersLeft {
                    joiner = " und "
                }
                if user.uID == GlobalVar.currentUid {
                    label += joiner + "du"
                } else {
                    label += joiner + user.firstname
                }
                count++
            }
        }
        label += verb
        label += "\(transfer.moneyPayed.toMoneyString()) für \(transfer.name) bezahlt"
        return label
    }
}
