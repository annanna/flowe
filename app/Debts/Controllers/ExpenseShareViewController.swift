//
//  ExpenseShareViewController.swift
//  Debts
//
//  Created by Anna on 06.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class ExpenseShareViewController: UIViewController {
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var automaticSliders: UISwitch!
    @IBOutlet weak var shareTableView: UITableView!
    @IBOutlet weak var resetBtn: UIButton!
    
    var detail = false
    var amount: Double = 0
    var originalAmount: Double = 0
    var cells: [ShareTableViewCell] = []
    var shares: [(user: User, amount:Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.shareTableView.tableFooterView = backgroundView
        self.shareTableView.backgroundColor = UIColor.whiteColor()
        self.originalAmount = self.amount
        self.totalAmountLabel.text = self.amount.toMoneyString()
        
        if detail {
            self.shareTableView.userInteractionEnabled = false
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
        return shares.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareCell", forIndexPath: indexPath) as! ShareTableViewCell
        var currentShare = shares[indexPath.row]
        cell.nameLabel.text = currentShare.user.firstname
        cell.sliderMax.text = self.amount.toMoneyString()
        cell.amountText.text = currentShare.amount.toMoneyString()
        cell.amountText.addTarget(self, action: "amountTextEditingEnd:", forControlEvents: UIControlEvents.EditingDidEnd)
        cell.amountSlider.maximumValue = Float(self.amount)
        cell.amountSlider.value = Float(currentShare.amount)
        cell.amountSlider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cells.append(cell)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    

    // MARK: Actions
    func sliderChanged(slider: UISlider!) {
        // update amount
        var cell: ShareTableViewCell = slider.superview?.superview as! ShareTableViewCell
        var idx = find(cells, cell)!
        shares[idx].amount = Double(slider.value).roundToMoney()
        
        if (automaticSliders.on && (idx < cells.count-1)) {
            // calculate remaining amount
            var rest:Double = amount
            for var k=0; k<=idx; k++ {
                rest -= shares[k].amount
            }
            
            if rest >= 0 {
                self.updateCellsWithShare(++idx, total: rest, c: cells.count-idx)
            } else {
                updateAmountLabel()
            }
        } else {
            updateAmountLabel()
        }
    }

    func amountTextEditingEnd(amountText: UITextField!) {
        var cell: ShareTableViewCell = amountText.superview?.superview as! ShareTableViewCell
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
        self.updateCellsWithShare(0, total: amount, c: shares.count)
    }
    
    func setTotal(total: Double) {
        self.totalAmountLabel.text = total.toMoneyString()
        self.amount = total
    }
    
    func updateCellsWithShare(index: Int, total: Double, c: Int) {
        var idx = index
        let count = Double(c)
        let totalMoney = total.roundToMoney()
        
        let part = (totalMoney/count).roundToMoney()
        let diff = totalMoney - (part*count)
        
        if diff != 0 {
            let firstAmount = part+diff
            shares[idx] = (user: shares[idx].user, amount: firstAmount)
            cells[idx].updateCell(Float(firstAmount))
            idx++
        }
        
        for (var i=idx; i<cells.count; i++) {
            shares[i] = (user: shares[i].user, amount: part)
            cells[i].updateCell(Float(part))
        }
    }
}