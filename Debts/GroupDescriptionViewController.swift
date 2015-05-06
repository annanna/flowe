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
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func cancelToGroupDescription(segue: UIStoryboardSegue) {}
    @IBAction func saveNewTransfer(segue: UIStoryboardSegue) {
        if let addTransferVC = segue.sourceViewController as? TransferTableViewController {
            addNewTransfer(addTransferVC.transfer)
        }
    }
    
    let addTransferIdentifier = "addTransfer"
    let transferDetailIdentifier = "showTransfer"
    
    var group:Group?
    let transferCell = "transferCell"
    
    func configureView() {
        if let gr: Group = self.group {
            self.title = gr.name
            if let peopleV = self.peopleView {
                for user in gr.users {
                    let btn = createBtn(user)
                    peopleV.addSubview(btn)
                }
            }
            updateSumLabel(gr.total)
        }
        // auto height of cells
        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()

        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()
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
        
        cell.textLabel?.text = generateTransferConclusion(group!.transfers[indexPath.row])
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
    }
    
    // MARK: Actions

    func addNewTransfer(transfer: MoneyTransfer) {
        if let gr = self.group {
            gr.addTransfer(transfer)
            let indexPath = NSIndexPath(forRow: gr.transfers.count-1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            updateSumLabel(gr.total)
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == transferDetailIdentifier {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                if let transfer = group?.transfers[indexPath.row] as MoneyTransfer! {
                    let vc = segue.destinationViewController as! TransferTableViewController
                    vc.transfer = transfer
                    if let gr = self.group {
                        vc.group = gr
                    }
                }
            }
        } else if segue.identifier == addTransferIdentifier {
            // TransferTableViewController is embedded in UINavigationController because of modal presentation
            let nav = segue.destinationViewController as! UINavigationController
            let transferVC = nav.topViewController as! TransferTableViewController
            if let gr = self.group {
                transferVC.group = gr
            }
        }
    }
    
    var btnX:CGFloat = 20;
    let btnY:CGFloat = 15;
    let btnSize:CGFloat = 40;
    func createBtn(user: User) -> PeopleButton {
        var rect:CGRect = CGRectMake(btnX, btnY, btnSize, btnSize)
        var btn = PeopleButton(frame: rect, user: user)
        btnX += btnSize + btnSize/2
        return btn
    }
    
    func updateSumLabel(total: Double) {
        if let sumLabel = self.sumLabel {
            sumLabel.text = String(format: "%.2f€", total)
            if total < 0 {
                sumLabel.textColor = UIColor.redColor()
            } else {
                sumLabel.textColor = UIColor.greenColor()
            }
        }
    }
    
    func generateTransferConclusion(transfer: MoneyTransfer) -> String {
        var label = transfer.payed[0].user.firstname
        var usersLeft = transfer.payed.count-1
        var count = 1
        var verb = " hat "
        
        var joiner = ""
        if usersLeft > 0 {
            joiner = ", "
            verb = " haben "
        
            for (user, amount) in transfer.payed[1...usersLeft] {
                if count == usersLeft {
                    joiner = " und "
                }
                label += joiner + user.firstname
                count++
            }
        }
        label += verb
        
        label += String(format: "%2.f€ für \(transfer.name) bezahlt", transfer.moneyPayed)
        return label
    }
}
