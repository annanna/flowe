//
//  ExpenseTableViewController.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class ExpenseTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var expenseName: UITextField!
    @IBOutlet weak var expenseAmount: UITextField!
    @IBOutlet weak var expenseNotes: UITextView!
    @IBOutlet weak var payerView: UIView!
    @IBOutlet weak var participantView: UIView!
    @IBOutlet weak var imgCell: UITableViewCell!
    
    let saveExpenseIdentifier = "SaveExpense"
    let paymentDetailIdentifier = "WhoPayed"
    let participantDetailIdentifier = "WhoTookPart"
    var imagePicker = UIImagePickerController()
    var lastIdentifier = ""
    
    var expense: Expense?
    var expenseId: String?
    
    var groupMembers = [User]()
    var groupId = ""
    
    var whoPayed: [(user: User, amount:Double)] = []
    var whoTookPart: [(user: User, amount:Double)] = []
    
    let editingMode = true //depends on the user's rights
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        self.setUpView()
        self.imagePicker.delegate = self
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let eId = expenseId {
            return false // is push
        }
        return true // is modal
    }
    
    func setUpView() {
        drawGroupMembersInViews()
        if let eId = expenseId {
            // Expense Detail
            RequestHelper.getExpenseDetails(self.groupId, expenseId: eId, callback: { (expenseData) -> Void in
                self.expense = expenseData
                self.loadDataInDetailView(expenseData)
                self.imgCell.hidden = true
                self.tableView.reloadData()
                
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
            peopleView.setPeopleInView(self.groupMembers)
            if let ex = expense {
                var toggleUsers = [User]()
                for (i,user) in enumerate(self.groupMembers) {
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
                var shares:[(user: User, amount:Double)]
                if let ex = expense {
                    // Expense Detail
                    shares = (segue.identifier == paymentDetailIdentifier) ? ex.payed : ex.participated
                    vc.detail = true
                } else {
                    // Add Expense
                    shares = getSelectedUsers(segue.identifier!)
                }
                vc.amount = getExpenseAmountFromTextField()
                vc.shares = shares
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
    @IBAction func chooseImage(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveShare(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? ExpenseShareViewController {
            self.expenseAmount.text = vc.amount.toMoneyString()
            if self.lastIdentifier == paymentDetailIdentifier {
                self.whoPayed = vc.shares
            } else {
                self.whoTookPart = vc.shares
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
                        whoPayed += [(user:btn.uid, amount:0.0)]
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
        var shares = payment
        var userCount = Double(payment.count)
        var total = getExpenseAmountFromTextField()
        
        var part:Double = (total / userCount).roundToMoney()
        let diff: Double = total - (part*userCount)
        
        for (idx,share) in enumerate(shares) {
            shares[idx] = (user:share.user, amount:part)
        }
        // in case of rounding issues (e.g. 10€ for 3 people) add the remaining difference to the first user (difference can be positive or negative
        if diff != 0 {
            shares[0] = (user: shares[0].user, amount: part+diff)
        }
        
        return shares
    }
    
    func getExpenseAmountFromTextField() -> Double {
        return expenseAmount.text.toDouble().roundToMoney()
    }
}
