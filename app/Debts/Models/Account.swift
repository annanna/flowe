//
//  Account.swift
//  Debts
//
//  Created by Anna on 23.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftyJSON

class Account: NSObject {
    var aId = ""
    var debtor = GlobalVar.currentUser
    var creditor = GlobalVar.currentUser
    var amount = 0.0
    var status = 0
    var updated = NSDate()
    
    init(debtor: User, creditor: User) {
        self.debtor = debtor
        self.creditor = creditor
    }
    
    init(data: JSON) {
        self.aId = data["_id"].stringValue
        self.amount = data["amount"].doubleValue
        self.status = data["status"].numberValue as Int
        
        let debtorId = data["debtor"].stringValue
        let creditorId = data["creditor"].stringValue
        super.init()
        UserHelper.getUserById(debtorId, callback: { (debtor) -> Void in
            self.debtor = debtor
        })
        UserHelper.getUserById(creditorId, callback: { (creditor) -> Void in
            self.creditor = creditor
        })
    }
    
    func asDictionary() -> [String: String] {
        return [
            "aId": self.aId,
            "debtor": self.debtor.uID,
            "creditor": self.creditor.uID,
            "amount": "\(self.amount)",
            "status": "\(self.status)"
        ]
    }
}