//
//  MoneyTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 04.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class MoneyTransferTableViewController: UITableViewController {
    
    var mode = ""
    var detail = false
    var amount: Double = 0
    var sliders: [UISlider] = []
    var cells: [BalanceTableViewCell] = []
    var balances: [(user: User, amount:Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(amount) €"
        
        // hide empty cells
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        if !detail {
            // calculate balances -> every person pays equal money
            var part:Double = round(amount / Double(balances.count) * 100) / 100
            var idx = 0
            for balance in balances {
                balances[idx] = (user:balance.user, amount:part)
                idx++
            }
        } else {
            self.tableView.userInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return balances.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("balanceCell", forIndexPath: indexPath) as! BalanceTableViewCell
        var currentBalance = balances[indexPath.row]
        cell.nameLabel.text = currentBalance.user.firstname
        cell.sliderMax.text = "\(self.amount)€"
        cell.amountLabel.text = "\(currentBalance.amount)€"
        cell.amountSlider.maximumValue = Float(self.amount)
        cell.amountSlider.value = Float(currentBalance.amount)
        cell.amountSlider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cells.append(cell)
        return cell
    }
    
    func sliderChanged(slider: UISlider!) {
        var cell: BalanceTableViewCell = slider.superview?.superview as! BalanceTableViewCell
        var idx = find(cells, cell) as Int!
        
        balances[idx].amount = Double(slider.value)

        var rest:Float = Float(amount) - slider.value
        var newAmount:Float = rest / Float(cells.count-1)
        if idx < cells.count-1 {
            for var i = idx+1; i < cells.count; i++ {
                cells[i].updateCell(newAmount)
                balances[i] = (user:balances[i].user, amount:Double(newAmount))
            }
        }
    }
}
