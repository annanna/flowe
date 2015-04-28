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
            transfer = MoneyTransfer(name: transferName.text, creator: whoPayed[0], money: (transferAmount.text as NSString).doubleValue)
        } else
        if segue.identifier == "WhoPayed" {
            if let vc = segue.destinationViewController as? ContactTableViewController {
                vc.mode = "WhoPayed"
            }
        } else
        if segue.identifier == "WhoTookPart" {
            if let vc = segue.destinationViewController as? ContactTableViewController {
                vc.mode = "WhoPayedFor"
            }
        }
    }
    
    @IBAction func selectContact(segue:UIStoryboardSegue) {
        println(segue.identifier)
        if let vc = segue.sourceViewController as? ContactTableViewController {
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            
            whoPayed = vc.selectedUsers
            
            for user in whoPayed {
                if let userView = (vc.mode == "WhoPayed" ? self.payerView : self.participantView) {
                    var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), title: user.getName())
                    userView.addSubview(btn)
                    btnX += btnSize + btnSize/2
                }
            }
        }
    }
}
