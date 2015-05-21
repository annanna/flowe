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
    
    let saveTransferIdentifier = "SaveTransfer"
    let paymentDetailIdentifier = "WhoPayed"
    let participantDetailIdentifier = "WhoTookPart"
    var lastIdentifier = ""
    
    var transfer: MoneyTransfer?
    var group:Group!
    
    var whoPayed: [(user: User, amount:Double)] = []
    var whoTookPart: [(user: User, amount:Double)] = []
    
    let editingMode = true //depends on the user's rights
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let t = transfer {
            return false // is push
        }
        return true // is modal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        self.setUpView()
    }
    
    // MARK: Set up view and load data
    
    func setUpView() {
        if let t = transfer {
            // Transfer Detail
            loadDataInDetailView(t)
            self.title = "\(t.name) Details"
            
            if editingMode {
                var editBtn: UIBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Done, target: self, action: "enableEditing:")
                navigationItem.rightBarButtonItem = editBtn
            }
        } else {
            // New Transfer
            var cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack:")
            navigationItem.leftBarButtonItem = cancelBtn
            var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveTransfer:")
            navigationItem.rightBarButtonItem = saveBtn
            self.title = "Add Transfer"
        }
        drawGroupMembersInViews()
    }

    func loadDataInDetailView(transfer: MoneyTransfer) {
        if let name = self.transferName {
            name.text = transfer.name
            name.userInteractionEnabled = false
        }
        if let amount = self.transferAmount {
            amount.text = transfer.moneyPayed.toMoneyString()
            amount.userInteractionEnabled = false
        }
        if let notes = self.transferNotes {
            notes.text = transfer.notes
            notes.userInteractionEnabled = false
        }
    }

    func drawGroupMembersInViews() {
        if let payer = self.payerView {
            fillView(payer, identifier: paymentDetailIdentifier)
        }
        if let participants = self.participantView {
            fillView(participants, identifier: participantDetailIdentifier)
        }
    }
    
    func fillView(currentView: UIView, identifier: String) {
        let btnY:CGFloat = 15
        let btnSize:CGFloat = 40
        var btnX:CGFloat = 20
        
        for user in group.users {
            var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), user: user)
            btn.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            currentView.addSubview(btn)
            btnX += btnSize + btnSize/2
            
            if let t = transfer {
                var markBtnAsClick = identifier == paymentDetailIdentifier ? t.hasPayed(user) : t.hasParticipated(user)
                if markBtnAsClick {
                    btn.toggleSelection()
                }
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == saveTransferIdentifier {
            if let t = self.transfer {
                // TODO: update this transfer
            } else {
                var newTransfer = MoneyTransfer(name: transferName.text, creator: GlobalVar.currentUser, money: getTransferAmountFromTextField(), notes: transferNotes.text)
                if whoPayed.count == 0 {
                    whoPayed = getSelectedUsers(paymentDetailIdentifier)
                }
                if whoTookPart.count == 0 {
                    whoTookPart  = getSelectedUsers(participantDetailIdentifier)
                }
                newTransfer.payed = whoPayed
                newTransfer.participated = whoTookPart

                self.transfer = newTransfer
            }
        } else if (segue.identifier == paymentDetailIdentifier) || (segue.identifier == participantDetailIdentifier) {
            if let vc = segue.destinationViewController as? BalancesViewController {
                var balances:[(user: User, amount:Double)]
                if let t = transfer {
                    // Transfer Detail
                    balances = (segue.identifier == paymentDetailIdentifier) ? t.payed : t.participated
                    vc.detail = true
                } else {
                    // Add Transfer
                    balances = getSelectedUsers(segue.identifier!)
                }
                vc.amount = getTransferAmountFromTextField()
                vc.balances = balances
            }
            self.lastIdentifier = segue.identifier!
        }
    }
    
    // MARK: Action Methods
    
    func goBack(cancelBtn: UIBarButtonItem) {
        self.performSegueWithIdentifier("CancelToGroupDescription", sender: self)
    }
    func saveTransfer(saveBtn: UIBarButtonItem) {
        self.performSegueWithIdentifier("SaveTransfer", sender: self)
    }
    func enableEditing(editBtn: UIBarButtonItem) {
        //TODO: enable all labels and buttons and store updated transfer
        var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveTransfer:")
        navigationItem.rightBarButtonItem = saveBtn
    }
    func buttonPressed(btn: PeopleButton) {
        btn.toggleSelection()
    }
    @IBAction func saveBalance(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? BalancesViewController {
            self.transferAmount.text = vc.amount.toMoneyString()
            if self.lastIdentifier == paymentDetailIdentifier {
                self.whoPayed = vc.balances
            } else {
                self.whoTookPart = vc.balances
            }
        }
    }
    
    func getSelectedUsers(identifier: String) -> [(user: User, amount:Double)] {
        if identifier == paymentDetailIdentifier {
            if let payer = payerView {
                whoPayed = []
                var btns:[PeopleButton] = payer.subviews as! [PeopleButton]
                for btn in btns {
                    if btn.isClicked {
                        whoPayed += [(user:btn.uid, amount:0.0)]
                    }
                }
                whoPayed = updateAmount(whoPayed)
                return whoPayed
            }
        } else {
            if let participant = participantView {
                whoTookPart = []
                var btns:[PeopleButton] = participant.subviews as! [PeopleButton]
                for btn in btns {
                    if btn.isClicked {
                        whoTookPart += [(user: btn.uid, amount:0.0)]
                    }
                }
                whoTookPart = updateAmount(whoTookPart)
                return whoTookPart
            }
        }
        return []
    }
    
    func updateAmount(payment:[(user: User, amount:Double)]) -> [(user: User, amount:Double)] {
        var balances = payment
        var userCount = Double(payment.count)
        var total = getTransferAmountFromTextField()
        
        var part:Double = (total / userCount).roundToMoney()
        for (idx,balance) in enumerate(balances) {
            balances[idx] = (user:balance.user, amount:part)
            total -= part
        }
        // in case of rounding issues (e.g. 10€ for 3 people) add the remaining difference to the first user (difference can be positive or negative
        if total != 0 {
            balances[0] = (user: balances[0].user, amount: part+total)
        }
        
        return balances
    }
    
    func getTransferAmountFromTextField() -> Double {
        return transferAmount.text.toDouble().roundToMoney()
    }
}
