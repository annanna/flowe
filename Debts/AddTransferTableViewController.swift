//
//  AddTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

/*protocol NewTransferDelegate {
    func AddNewTransfer(transfer: MoneyTransfer)
}*/

class AddTransferTableViewController: UITableViewController {

    @IBOutlet weak var transferName: UITextField!
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var transferNotes: UITextView!
    @IBOutlet weak var whoPayedLabel: UILabel!
    
    //var delegate:NewTransferDelegate? = nil
    var transfer: MoneyTransfer!
    var whoPayed:String = "Anna"
     
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            transferName.becomeFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveTransfer" {
            transfer = MoneyTransfer(name: transferName.text, creator: User(rand: 1), money: (transferAmount.text as NSString).doubleValue)
        }
        if segue.identifier == "WhoPayed" {
            if let vc = segue.destinationViewController as? ContactTableViewController {
                // vc.selectedContact = contact
            }
        }
    }
    
    @IBAction func selectContact(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? ContactTableViewController {
            // whoPayed = vc.contact
        }
    }
}
