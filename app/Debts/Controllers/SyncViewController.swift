//
//  SyncViewController.swift
//  Debts
//
//  Created by Anna on 07.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class SyncViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sendingTableview: UITableView!
    @IBOutlet weak var receivingBtn: UIButton!
    
    var group:Group!
    var expenses = [Expense]()
    var groupId: String = ""
    
    var selectedExpense: Expense?
    
    let expenseCellIdentifier = "sendingCell"
    let qrCodeCreatorIdentifier = "generateQRCode"
    let qrCodeScanIdentifier = "scanQRCode"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.receivingBtn.setTitle("Empfange Event für \(group.name)", forState: UIControlState.Normal)
    }
    
    // MARK: - Table view data source & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(expenseCellIdentifier, forIndexPath: indexPath) 
        cell.textLabel?.text = expenses[indexPath.row].name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.row)")
        self.selectedExpense = self.expenses[indexPath.row]
        self.performSegueWithIdentifier(qrCodeCreatorIdentifier, sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == qrCodeCreatorIdentifier {
            if let creatorVC = segue.destinationViewController as? QRCodeCreatorViewController {
                creatorVC.expense = self.selectedExpense!
                creatorVC.groupId = self.groupId
            }
        } else if segue.identifier == qrCodeScanIdentifier {
            if let scanVC = segue.destinationViewController as? QRCodeScannerViewController {
                scanVC.groupdId = self.groupId
            }
        }
    }
    
    

}
