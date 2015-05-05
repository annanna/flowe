//
//  MoneyTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 04.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class MoneyTransferTableViewController: UITableViewController {
    
    var selectedUsers:[User] = []
    var mode = ""
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
        
        if selectedUsers.count > 0 && balances.count == 0 {
            // transform to balances -> every person pays equal money
            var part:Double = round(amount / Double(selectedUsers.count) * 100) / 100
            for user in selectedUsers {
                self.balances += [(user:user, amount:part)]
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

        var rest = Float(amount) - slider.value
        if idx < cells.count-1 {
            for var i = idx+1; i < cells.count; i++ {
                cells[i].updateCell(rest / Float(cells.count-1))
            }
        }
    }
}
