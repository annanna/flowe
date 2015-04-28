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
    @IBOutlet weak var payerView: UIView!
    @IBOutlet weak var participantView: UIView!
    
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
            let btnY:CGFloat = 15
            let btnSize:CGFloat = 40
            var btnX:CGFloat = 20
            if let payer = self.payerView {
                var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), title: transfer.userPayed.getName())
                payer.addSubview(btn)
            }
            
            if let participants = self.participantView {
                for user in transfer.participants {
                    var btn = PeopleButton(frame: CGRectMake(btnX, btnY, btnSize, btnSize), title: user.user.getName())
                    participants.addSubview(btn)
                    btnX += btnSize + btnSize/2
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
