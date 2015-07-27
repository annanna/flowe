//
//  ExpenseTableViewController.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class ExpenseTableViewController: UITableViewController {

    @IBOutlet weak var expenseName: UITextField!
    @IBOutlet weak var expenseAmount: UITextField!
    @IBOutlet weak var expenseNotes: UITextView!
    @IBOutlet weak var payerView: UIView!
    @IBOutlet weak var participantView: UIView!
    
    let saveExpenseIdentifier = "SaveExpense"
    let paymentDetailIdentifier = "WhoPayed"
    let participantDetailIdentifier = "WhoTookPart"
    var lastIdentifier = ""
    
    var expense: Expense?
    var expenseId: String?
    var group:Group!
    
    var whoPayed: [(user: User, amount:Double)] = []
    var whoTookPart: [(user: User, amount:Double)] = []
    
    let editingMode = true //depends on the user's rights
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        self.setUpView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let ex = expense {
            return false // is push
        }
        return true // is modal
    }
    
    func setUpView() {
        if let eId = expenseId {
            // Expense Detail
            RequestHelper.getExpenseDetails(self.group.gID, expenseId: eId, callback: { (expenseData) -> Void in
                self.expense = expenseData
                self.loadDataInDetailView(expenseData)
                self.drawGroupMembersInViews()
                
                if self.editingMode {
                    var editBtn: UIBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Done, target: self, action: "enableEditing:")
                    self.navigationItem.rightBarButtonItem = editBtn
                }
            })
        } else {
            // New Expense
            var cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack:")
            navigationItem.leftBarButtonItem = cancelBtn
            var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveExpense:")
            navigationItem.rightBarButtonItem = saveBtn
            self.title = "Add Expense"
            drawGroupMembersInViews()
        }
    }

    func loadDataInDetailView(expense: Expense) {
        self.title = "\(expense.name) Details"
        
        if let name = self.expenseName {
            name.text = expense.name
            name.userInteractionEnabled = false
        }
        if let amount = self.expenseAmount {
            amount.text = "\(expense.moneyPayed)"
            amount.userInteractionEnabled = false
        }
        if let notes = self.expenseNotes {
            notes.text = expense.notes
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
        if let peopleView = currentView as? PeopleView {
            peopleView.userInteractionEnabled = self.editingMode
            peopleView.setPeopleInView(group.getUsers())
            if let ex = expense {
                var toggleUsers = [User]()
                for (i,user) in enumerate(group.getUsers()) {
                    var markBtnAsClick = identifier == paymentDetailIdentifier ? ex.hasPayed(user) : ex.hasParticipated(user)
                    if markBtnAsClick {
                        toggleUsers.append(user)
                    }
                }
                peopleView.setActivePeopleInView(toggleUsers)
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == saveExpenseIdentifier {
            if let ex = self.expense {
                // TODO: update this expense
            } else {
                var newExpense = Expense(name: expenseName.text, creator: GlobalVar.currentUser, money: getExpenseAmountFromTextField(), notes: expenseNotes.text)
                if whoPayed.count == 0 {
                    whoPayed = getSelectedUsers(paymentDetailIdentifier)
                }
                if whoTookPart.count == 0 {
                    whoTookPart  = getSelectedUsers(participantDetailIdentifier)
                }
                newExpense.payed = whoPayed
                newExpense.participated = whoTookPart

                self.expense = newExpense
            }
        } else if (segue.identifier == paymentDetailIdentifier) || (segue.identifier == participantDetailIdentifier) {
            if let vc = segue.destinationViewController as? ExpenseShareViewController {
                var balances:[(user: User, amount:Double)]
                if let ex = expense {
                    // Expense Detail
                    balances = (segue.identifier == paymentDetailIdentifier) ? ex.payed : ex.participated
                    vc.detail = true
                } else {
                    // Add Expense
                    balances = getSelectedUsers(segue.identifier!)
                }
                vc.amount = getExpenseAmountFromTextField()
                vc.balances = balances
            }
            self.lastIdentifier = segue.identifier!
        }
    }
    
    // MARK: Action Methods
    
    func goBack(cancelBtn: UIBarButtonItem) {
        self.performSegueWithIdentifier("CancelToGroupDescription", sender: self)
    }
    func saveExpense(saveBtn: UIBarButtonItem) {
        self.performSegueWithIdentifier("SaveExpense", sender: self)
    }
    func enableEditing(editBtn: UIBarButtonItem) {
        //TODO: enable all labels and buttons and store updated expense
        var saveBtn: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "saveExpense:")
        navigationItem.rightBarButtonItem = saveBtn
    }
    @IBAction func saveBalance(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? ExpenseShareViewController {
            self.expenseAmount.text = vc.amount.toMoneyString()
            if self.lastIdentifier == paymentDetailIdentifier {
                self.whoPayed = vc.balances
            } else {
                self.whoTookPart = vc.balances
            }
        }
    }
    
    func getSelectedUsers(identifier: String) -> [(user: User, amount:Double)] {
        if identifier == paymentDetailIdentifier {
            if let payer = payerView as? PeopleView {
                whoPayed = []
                var btns:[PeopleButton] = payer.peopleBtns
                for btn in btns {
                    if btn.isClicked {
                        //whoPayed.append(user: btn.uid, amount: 0.0)
                        //let inst = [(user:btn.uid, amount:0.0)]
                        //whoPayed[whoPayed.count+1] = inst
                        
//                        whoPayed += [(user:btn.uid, amount:0.0)]
                    }
                }
                whoPayed = updateAmount(whoPayed)
                return whoPayed
            }
        } else {
            if let participant = participantView as? PeopleView {
                whoTookPart = []
                var btns:[PeopleButton] = participant.peopleBtns
                for btn in btns {
                    if btn.isClicked {
                        
                        
                        //whoTookPart += [(user: btn.uid, amount:0.0)]
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
        var total = getExpenseAmountFromTextField()
        
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
    
    func getExpenseAmountFromTextField() -> Double {
        return expenseAmount.text.toDouble().roundToMoney()
    }
}
