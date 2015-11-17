//
//  GroupDescriptionViewController.swift
//  Debts
//
//  Created by Anna on 22.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var sumBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let addExpenseIdentifier = "addExpense"
    let expenseDetailIdentifier = "showExpense"
    let expenseCell = "expenseCell"
    let accountIdentifier = "showAccount"
    let syncIdentifier = "showSync"
    
    var group:Group?
    var expenses = [Expense]()
    var groupId: String = ""
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGroupDetails()
    }
    
    func getGroupDetails() {
        RequestHelper.getGroupDetails(self.groupId, callback: { (groupData) -> Void in
            self.group = groupData
            self.expenses = groupData.expenses
            
            self.configureView()
            self.tableView.reloadData()
        })
    }
    
    func configureView() {
        self.title = group!.name
        if let peopleV = self.peopleView as? PeopleView {
            peopleV.setPeopleInView(group!.users)
        }
        
        updateSumLabel()
        
        // auto height of cells
        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // hide empty cells
        let backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()

    }
    
    // MARK: - Table view data source & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.expenses.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(expenseCell, forIndexPath: indexPath) 
        let expense = self.expenses[indexPath.row]
        cell.textLabel?.text = expense.generateConclusion()
        return cell
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == expenseDetailIdentifier {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let expense = self.expenses[indexPath.row] as Expense! {
                    let vc = segue.destinationViewController as! ExpenseTableViewController
                    vc.expenseId = expense.eID
                    vc.groupId = group!.gID
                    vc.groupMembers = group!.users
                }
            }
        } else if segue.identifier == addExpenseIdentifier {
            // ExpenseTableViewController is embedded in UINavigationController because of modal presentation
            let nav = segue.destinationViewController as! UINavigationController
            let expenseVC = nav.topViewController as! ExpenseTableViewController
            expenseVC.groupMembers = self.group!.users

        }  else if segue.identifier == accountIdentifier {
            if let financeVC = segue.destinationViewController as? AccountViewController {
                financeVC.total = self.group!.total
                financeVC.groupId = self.group!.gID
            }
        } else if segue.identifier == syncIdentifier {
            
            if let syncVC = segue.destinationViewController as? SyncViewController {
                syncVC.groupId = self.groupId
                syncVC.group = self.group!
                syncVC.expenses = self.expenses
            }
        }
    }

    // MARK: Actions
    
    @IBAction func cancelToGroupDescription(segue: UIStoryboardSegue) {}
    @IBAction func saveNewExpense(segue: UIStoryboardSegue) {
        if let addExpenseVC = segue.sourceViewController as? ExpenseTableViewController {
            if let ex = addExpenseVC.expense {
                RequestHelper.createExpense(self.groupId, expense: ex, callback: { (expense) -> Void in
                    self.addNewExpense(expense)
                })
            }
        } else if let qrCodeExpenseVC = segue.sourceViewController as? QRCodeScannerViewController {
            if let ex = qrCodeExpenseVC.expense {
                print(ex.name)
                self.addNewExpense(ex)
                /*RequestHelper.postExpense(self.groupId, expense: ex, callback: { (expense) -> Void in
                    //self.addNewExpense(expense)
                    println(expense.name)
                })*/
            }
        }
    }
    
    func addNewExpense(expense: Expense) {
        self.expenses.insert(expense, atIndex: 0)
        let path = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Bottom)
        self.group?.updateTotal(expense)
        self.updateSumLabel()
    }
    
    func updateSumLabel() {
        if let sum = self.sumBtn {
            let total = group!.total
            sum.setTitle(total.toMoneyString(), forState: UIControlState.Normal)
            if total < 0 {
                sum.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            } else {
                sum.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
            }
        }
    }
}