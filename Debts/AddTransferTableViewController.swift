//
//  AddTransferTableViewController.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
protocol NewTransferDelegate {
    func AddNewTransfer(transfer: MoneyTransfer)
}

class AddTransferTableViewController: UITableViewController {

    @IBOutlet weak var transferName: UITextField!
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var transferNotes: UITextView!
    
    var delegate:NewTransferDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func saveAndGoBack(sender: UIButton) {
        let t = MoneyTransfer(name: transferName.text, creator: User(rand: 1), money: (transferAmount.text as NSString).doubleValue)
        if let d = delegate {
            d.AddNewTransfer(t)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}
