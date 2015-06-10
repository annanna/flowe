//
//  FinanceViewController.swift
//  
//
//  Created by Anna on 12.05.15.
//
//

import UIKit

class FinanceViewController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var accountTableView: UITableView!
    
    var total:Double = 0
    var groupId = ""
    var accounts: [(user: User, action: String, amount: Double, partner: User)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.totalLabel.text = self.total.toMoneyString()
        self.getAccounts()
    }
    
    func getAccounts() {
        RequestHelper.getFinance(groupId, callback: { (accountData) -> Void in
            self.accounts = accountData
            self.accountTableView.reloadData()
        })
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
        var currentAccount:(user: User, action: String, amount: Double, partner: User) = self.accounts[indexPath.row]
        var adverb = currentAccount.action == "pay" ? "to" : "from"
        cell.textLabel?.text = "\(currentAccount.action.capitalizedString) \(currentAccount.amount)€ \(adverb) \(currentAccount.partner.firstname)"
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
    }
    
}