//
//  TransferDetailTableViewController.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class TransferDetailTableViewController: UITableViewController {
    
    var transfer: MoneyTransfer?

    @IBOutlet weak var transferName: UILabel!
    @IBOutlet weak var transferAmount: UILabel!
    @IBOutlet weak var transferNotes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let transfer: MoneyTransfer = self.transfer {
            if let name = self.transferName {
                name.text = transfer.name
            }
            if let amount = self.transferAmount {
                amount.text = String(format: "%.2f",transfer.moneyPayed)
            }
            if let notes = self.transferNotes {
                notes.text = transfer.notes
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
