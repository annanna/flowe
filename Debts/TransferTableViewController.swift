//
//  AddTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class TransferTableViewController: UITableViewController {

    @IBOutlet weak var transferName: UITextField!
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var transferNotes: UITextView!
    @IBOutlet weak var payerView: UIView!
    @IBOutlet weak var participantView: UIView!
    @IBOutlet weak var payerInfo: UIButton!
    @IBOutlet weak var participantInfo: UIButton!
    
    var transfer: MoneyTransfer!
    var whoPayed: [(user: User, amount:Double)] = []
    var whoTookPart: [(user: User, amount:Double)] = []
    
    var editingMode = true //depends on the user's rights
    var detail = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        if let t = transfer {
            loadDataInDetailView(t)
            self.title = "\(transfer.name) Details"
            
            if editingMode {
                var editBtn: UIBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Done, target: self, action: "enableEditing:")
                navigationItem.rightBarButtonItem = editBtn
            }
        } else {
            var cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack:")
            navigationItem.leftBarButtonItem = cancelBtn
            var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveTransfer:")
            navigationItem.rightBarButtonItem = saveBtn
            self.title = "Add Transfer"
        }
    }
    
    func goBack(cancelBtn: UIBarButtonItem) {
        self.performSegueWithIdentifier("CancelToGroupDescription", sender: self)
    }
    func saveTransfer(saveBtn: UIBarButtonItem) {
        self.performSegueWithIdentifier("SaveTransfer", sender: self)
    }
    func enableEditing(editBtn: UIBarButtonItem) {
        self.tableView.userInteractionEnabled = true
        var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveTransfer:")
        navigationItem.rightBarButtonItem = saveBtn
    }
    
    func loadDataInDetailView(transfer: MoneyTransfer) {
        if let name = self.transferName {
            name.text = transfer.name
            name.userInteractionEnabled = false
        }
        if let amount = self.transferAmount {
            amount.text = String(format: "%.2f",transfer.moneyPayed)
            amount.userInteractionEnabled = false
        }
        if let notes = self.transferNotes {
            notes.text = transfer.notes
            notes.userInteractionEnabled = false
        }
        if let payer = self.payerView {
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            for balance in transfer.payed {
                var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), user: balance.user)
                payer.addSubview(btn)
                btnX += btnSize + btnSize/2
            }
            if transfer.payed.count > 1 {
                payerInfo.hidden = false
            }
        }
        
        if let participants = self.participantView {
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            
            for balance in transfer.participated {
                var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), user: balance.user)
                participants.addSubview(btn)
                btnX += btnSize + btnSize/2
            }
            if transfer.participated.count > 1 {
                participantInfo.hidden = false
            }
        }
        whoPayed = transfer.payed
        whoTookPart = transfer.participated
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let t = transfer {
            return false
        }
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
        } else if (segue.identifier == "showParticipantInfo") || (segue.identifier == "showPayerInfo") {
            if let vc = segue.destinationViewController as? MoneyTransferTableViewController {
                vc.balances = (segue.identifier == "showParticipantInfo") ? whoTookPart : whoPayed
                vc.amount = (transferAmount.text as NSString).doubleValue
            }
        }
    }
    
    @IBAction func saveOnePerson(segue:UIStoryboardSegue) {
     if let vc = segue.sourceViewController as? ContactTableViewController {

        var balances = [(user: vc.selectedUsers[0], amount: vc.transferAmount)]
        evaluateSelectedContacts(balances, mode: vc.mode)
      }
    }
    
    @IBAction func selectContact(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? MoneyTransferTableViewController {
            evaluateSelectedContacts(vc.balances, mode: vc.mode)
        }
    }
    
    func evaluateSelectedContacts(balances:[(user: User, amount:Double)], mode: String) {
        let btnY:CGFloat = 15
        let btnSize:CGFloat = 40
        var btnX:CGFloat = 20
        
        var relevantView: UIView?
        
        if mode == "WhoPayed" {
            whoPayed = balances
            relevantView = self.payerView
            if balances.count > 1 {
                payerInfo.hidden = false
            }
        } else if mode == "WhoTookPart" {
            whoTookPart = balances
            relevantView = self.participantView
            if balances.count > 1 {
                participantInfo.hidden = false
            }
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
