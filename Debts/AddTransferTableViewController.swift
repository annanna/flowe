//
//  AddTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class AddTransferTableViewController: UITableViewController {

    @IBOutlet weak var transferName: UITextField!
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var transferNotes: UITextView!
    @IBOutlet weak var payerView: UIView!
    @IBOutlet weak var participantView: UIView!
    
    var transfer: MoneyTransfer!
    var whoPayed: [User] = []
    var whoTookPart: [User] = []
     
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
            transfer = MoneyTransfer(name: transferName.text, creator: whoPayed[0], money: (transferAmount.text as NSString).doubleValue, notes: transferNotes.text)
            transfer.addUsersInTransfers(whoTookPart)
        } else
        if segue.identifier == "WhoPayed" {
            if let vc = segue.destinationViewController as? ContactTableViewController {
                vc.mode = "WhoPayed"
            }
        } else
        if segue.identifier == "WhoTookPart" {
            if let vc = segue.destinationViewController as? ContactTableViewController {
                vc.mode = "WhoTookPart"
            }
        }
    }
    
    @IBAction func selectContact(segue:UIStoryboardSegue) {
        println(segue.identifier)
        if let vc = segue.sourceViewController as? ContactTableViewController {
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            
            var users = vc.selectedUsers
            var relevantView: UIView?
            
            if vc.mode == "WhoPayed" {
                whoPayed = users
                relevantView = self.payerView
            } else if vc.mode == "WhoTookPart" {
                whoTookPart = users
                relevantView = self.participantView
            }
            
            
            for user in users {
                if let userView = relevantView {
                    var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), title: user.getName())
                    userView.addSubview(btn)
                    btnX += btnSize + btnSize/2
                }
            }
        }
    }
}
