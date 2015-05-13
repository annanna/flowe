//
//  FinanceViewController.swift
//  
//
//  Created by Anna on 12.05.15.
//
//

import UIKit

class FinanceViewController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    
    var group:Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let totalL = totalLabel {
            var total = group.getFinanceForUser(GlobalVar.currentUser)
            var preSign = (total > 0 ? "+" : "")
            var financeTotal = " \(preSign) \(total) €"
            totalL.text = financeTotal
//            totalL.textColor = (total > 0 ? UIColor.greenColor() : UIColor.redColor())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
