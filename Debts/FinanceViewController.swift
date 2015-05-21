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
    var group:Group!
    var accounts: [(user: User, action: String, amount: Double, partner: User)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accounts = self.group.getAccountForUser(GlobalVar.currentUser)
        
        if let totalL = totalLabel {
            var total = group.getTotalFinanceForUser(GlobalVar.currentUser)
            var preSign = (total > 0 ? "+" : "")
            var financeTotal = preSign + total.toMoneyString()
            totalL.text = financeTotal
            totalL.textColor = (total > 0 ? UIColor.greenColor() : UIColor.redColor())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
