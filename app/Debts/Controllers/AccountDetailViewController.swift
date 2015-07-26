//
//  AccountDetailViewController.swift
//  Debts
//
//  Created by Anna on 26.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expenseTable: UITableView!
    @IBOutlet weak var accStatusLabel: UILabel!
    @IBOutlet weak var accTotalLabel: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!
    
    let cellIdentifier = "expenseCell"
    var expenses = [Expense]()
    var aId = ""
    var account: Account?
    var currentPersonIsCreditor:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RequestHelper.getAccountDetails(self.aId, callback: { (acc, exp) -> Void in
            self.expenses = exp
            self.account = acc
            self.setTopBar()
            self.expenseTable.reloadData()
        })
    }
    
    func setTopBar() {
        if let acc = self.account {
            var otherName = ""
            if acc.creditor.isSame(GlobalVar.currentUser) {
                // der andere hat Schulden bei mir
                currentPersonIsCreditor = true
                otherName = acc.debtor.firstname
                paymentBtn.titleLabel?.text = "Request Payment"
            } else {
                // ich habe Schulden
                currentPersonIsCreditor = false
                otherName = acc.creditor.firstname
                paymentBtn.titleLabel?.text = "Pay now"
            }
            titleLabel.text = "\(otherName) & Ich"
            accStatusLabel.text = "\(acc.status)"
            accTotalLabel.text = acc.amount.toMoneyString()
        }
    }
    
    // MARK: - Table view data source & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let expense = self.expenses[indexPath.row]
        cell.textLabel?.text = expense.generateConclusion()
        return cell
    }    
    
    @IBAction func paymentPressed(sender: UIButton) {
        if currentPersonIsCreditor {
            // send message and show alert
            let message = Message(sender: GlobalVar.currentUser, receiver: self.account!.debtor, message: " wants money from you!")
            RequestHelper.sendMessage(message, callback: { () -> Void in
                var alert = UIAlertController(title: "Message", message: "Message sent to \(self.account!.debtor.firstname)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                    self.accStatusLabel.text = "1"
                })
            })
            
        }
    }

}
