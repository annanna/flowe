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
        return selectedUsers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("balanceCell", forIndexPath: indexPath) as! BalanceTableViewCell
        var person = selectedUsers[indexPath.row]
        cell.nameLabel.text = person.firstname
        cell.sliderMax.text = "\(amount)€"
        var part:Double = round(amount / Double(selectedUsers.count) * 100) / 100
        cell.amountLabel.text = "\(part)€"
        cell.amountSlider.maximumValue = Float(amount)
        cell.amountSlider.value = Float(part)
        cell.amountSlider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cell.id = indexPath.row
        sliders.append(cell.amountSlider)
        cells.append(cell)
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveSelectedContacts" {
            var i = 0
            for cell in cells {
                var val: Double = Double(cell.amountSlider.value)
                balances += [(user: selectedUsers[i], amount: val)]
                i++
            }
        }
    }
    
    func sliderChanged(slider: UISlider!) {
        var cell: BalanceTableViewCell = slider.superview?.superview as! BalanceTableViewCell
        var idx = find(cells, cell) as Int!
        
        
        var rest = Float(amount) - slider.value
        if idx < cells.count-1 {
            for var i = idx+1; i < cells.count; i++ {
                cells[i].updateCell(rest / Float(cells.count-1))
            }
        }
    }
    
    func getCellForUser(user: User) -> BalanceTableViewCell {
        let idx = find(selectedUsers, user)
        return cells[idx!]
    }
}
