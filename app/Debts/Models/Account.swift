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
    var debtor: User
    var creditor: User
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
        if let deb = UserHelper.getUser(debtorId) {
            self.debtor = deb
        } else {
            println("kenn ich nicht")
            self.debtor = User(rand: 1)
        }
        
        let creditorId = data["creditor"].stringValue
        if let cred = UserHelper.getUser(creditorId) {
            self.creditor = cred
        } else {
            println("kenn ich nicht")
            self.creditor = User(rand: 2)
        }
        
    }
    
}
