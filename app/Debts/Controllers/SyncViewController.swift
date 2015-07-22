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
    var transfers = [MoneyTransfer]()
    var groupId: String = ""
    
    var selectedTransfer: MoneyTransfer?
    
    let transferCellIdentifier = "sendingCell"
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
        return transfers.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(transferCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = transfers[indexPath.row].name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(indexPath.row)")
        self.selectedTransfer = self.transfers[indexPath.row]
        self.performSegueWithIdentifier(qrCodeCreatorIdentifier, sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == qrCodeCreatorIdentifier {
            if let creatorVC = segue.destinationViewController as? QRCodeCreatorViewController {
                creatorVC.transfer = self.selectedTransfer!
                creatorVC.groupId = self.groupId
            }
        } else if segue.identifier == qrCodeScanIdentifier {
            if let scanVC = segue.destinationViewController as? QRCodeScannerViewController {
                scanVC.groupdId = self.groupId
            }
        }
    }
    
    

}
