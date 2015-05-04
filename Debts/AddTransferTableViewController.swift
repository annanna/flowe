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
    @IBOutlet weak var payerInfo: UIButton!
    
    var transfer: MoneyTransfer!
    var whoPayed: [(user: User, amount:Double)] = []
    var whoTookPart: [(user: User, amount:Double)] = []
    
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
            transfer = MoneyTransfer(name: transferName.text, creator: whoPayed[0].user, money: (transferAmount.text as NSString).doubleValue, notes: transferNotes.text)
            transfer.payed = whoPayed
            transfer.participated = whoTookPart
        } else if (segue.identifier == "WhoPayed") || (segue.identifier == "WhoTookPart") {
            if let vc = segue.destinationViewController as? ContactTableViewController {
                vc.mode = segue.identifier!
                vc.transferAmount = (transferAmount.text as NSString).doubleValue
            }
        }
    }
    
    @IBAction func selectContact(segue:UIStoryboardSegue) {
        println(segue.identifier)
        if let vc = segue.sourceViewController as? MoneyTransferTableViewController {
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            
            var users = vc.selectedUsers
            var balances = vc.balances
            var relevantView: UIView?
            
            if vc.mode == "WhoPayed" {
                whoPayed = balances
                relevantView = self.payerView
                if whoPayed.count > 1 {
                    payerInfo.hidden = false
                }
            } else if vc.mode == "WhoTookPart" {
                whoTookPart = balances
                relevantView = self.participantView
            }
            
            for b in balances {
                if let userView = relevantView {
                    var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), user: b.user)
                    btn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                    userView.addSubview(btn)
                    btnX += btnSize + btnSize/2
                }
            }
        }
    }
    
    func buttonAction(sender: PeopleButton!) {
        println("Button tapped")
        println(sender.uid.firstname)
    }
}
