//
//  FinanceViewController.swift
//  
//
//  Created by Anna on 12.05.15.
//
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var accountTableView: UITableView!
    
    let showDetailIdentifier = "accountDetails"
    
    var total:Double = 0
    var groupId:String?
    var accounts: [Account] = []
    var selectedAccount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAccounts()
    }
    
    func getAccounts() {
        if let g = groupId {
            RequestHelper.getAccountsByGroup(g, callback: { (accountData) -> Void in
                self.accounts = accountData
                self.accountTableView.reloadData()
                self.updateTotal()
            })
        } else {
            RequestHelper.getAccounts({ (accountData) -> Void in
                self.accounts = accountData
                self.accountTableView.reloadData()
            })
        }
    }
    
    func updateTotal() {
        for account in self.accounts {
            if account.currentUserIsDebtor() {
                total -= account.amount
            } else {
                total += account.amount
            }
        }
        self.totalLabel.text = total.toMoneyString()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("accountCell", forIndexPath: indexPath) as! UITableViewCell
        let acc = self.accounts[indexPath.row]
        if acc.currentUserIsDebtor() {
            cell.textLabel?.text = "\(acc.creditor.firstname) kriegt \(acc.amount.toMoneyString()) von mir"
        } else {
            cell.textLabel?.text = "Ich kriege \(acc.amount.toMoneyString()) von \(acc.debtor.firstname)"
        }

        cell.backgroundColor = colors.paymentColors[acc.status]
        
        return cell
    }
    
    // Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.showDetailIdentifier {
            if let indexPath = self.accountTableView.indexPathForSelectedRow() {
                let acc = self.accounts[indexPath.row]
                if let detailVC = segue.destinationViewController as? AccountDetailViewController {
                    detailVC.aId = acc.aId
                }
            }
        }
    }
    
}