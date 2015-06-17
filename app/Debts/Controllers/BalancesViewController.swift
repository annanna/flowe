//
//  BalancesViewController.swift
//  Debts
//
//  Created by Anna on 06.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class BalancesViewController: UIViewController {
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var automaticSliders: UISwitch!
    @IBOutlet weak var balanceTableView: UITableView!
    @IBOutlet weak var resetBtn: UIButton!
    
    var detail = false
    var amount: Double = 0
    var originalAmount: Double = 0
    var cells: [BalanceTableViewCell] = []
    var balances: [(user: User, amount:Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.balanceTableView.tableFooterView = backgroundView
        self.balanceTableView.backgroundColor = UIColor.whiteColor()
        self.originalAmount = self.amount
        self.totalAmountLabel.text = self.amount.toMoneyString()
        
        if detail {
            self.balanceTableView.userInteractionEnabled = false
            // hide save button and switch
            self.navigationItem.rightBarButtonItem = nil
            self.automaticSliders.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balances.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("balanceCell", forIndexPath: indexPath) as! BalanceTableViewCell
        var currentBalance = balances[indexPath.row]
        cell.nameLabel.text = currentBalance.user.firstname
        cell.sliderMax.text = self.amount.toMoneyString()
        cell.amountText.text = currentBalance.amount.toMoneyString()
        cell.amountText.addTarget(self, action: "amountTextEditingEnd:", forControlEvents: UIControlEvents.EditingDidEnd)
        cell.amountSlider.maximumValue = Float(self.amount)
        cell.amountSlider.value = Float(currentBalance.amount)
        cell.amountSlider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cells.append(cell)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    

    // MARK: Actions
    
    func sliderChanged(slider: UISlider!) {
        var cell: BalanceTableViewCell = slider.superview?.superview as! BalanceTableViewCell
        var idx = find(cells, cell) as Int!
        balances[idx].amount = Double(slider.value).roundToMoney()
        
        if automaticSliders.on {
            var rest:Double = amount
            for var k=0; k<=idx; k++ {
                rest -= balances[k].amount
            }
            if rest < 0 {
                updateAmountLabel()
            } else {
                var newAmount:Double = rest / Double(cells.count-1-idx)
                newAmount = newAmount.roundToMoney()
                if idx < cells.count-1 {
                    for var i = idx+1; i < cells.count; i++ {
                        cells[i].updateCell(Float(newAmount))
                        balances[i] = (user:balances[i].user, amount:newAmount)
                    }
                } else {
                    updateAmountLabel()
                }
            }
        } else {
            updateAmountLabel()
        }
    }
    
    func amountTextEditingEnd(amountText: UITextField!) {
        var cell: BalanceTableViewCell = amountText.superview?.superview as! BalanceTableViewCell
        var newVal = amountText.text.toDouble().toMoneyString()
        cell.amountSlider.value = newVal.toFloat()
        self.sliderChanged(cell.amountSlider)
    }
    
    func updateAmountLabel() {
        var total:Double = 0.0
        for cell in cells {
            total += Double(cell.amountSlider.value)
        }
        setTotal(total)
        self.resetBtn.hidden = false
    }
    
    @IBAction func resetBtnPressed(sender: UIButton) {
        setTotal(self.originalAmount)
        self.resetBtn.hidden = true
        // re-calculate that everyone pays the same
        var part:Double = round(amount / Double(balances.count) * 100) / 100
        var idx = 0
        for balance in balances {
            balances[idx] = (user:balance.user, amount:part)
            cells[idx].updateCell(Float(part))
            idx++
        }
    }
    
    func setTotal(total: Double) {
        self.totalAmountLabel.text = total.toMoneyString()
        self.amount = total
    }
}
