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
    @IBOutlet weak var payerView: UIView!
    
    
    //var delegate:NewTransferDelegate? = nil
    var transfer: MoneyTransfer!
     
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
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            
            var users = vc.selectedUsers
            for user in users {
                println(user.getName())
                if let payer = self.payerView {
                    var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), title: user.getName())
                    payer.addSubview(btn)
                    btnX += btnSize + btnSize/2
                }
            }
        }
    }
}
