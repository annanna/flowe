//
//  MoneyTransfer.swift
//  
//
//  Created by Anna on 25.04.15.
//
//

import UIKit

class MoneyTransfer: NSObject {
    var name = ""
    var timestamp = NSDate()
    var notes = ""
    var creator: User
    var moneyPayed = 0.0
    var imageLink = ""
    
    var payed: [(user: User, amount:Double)] = []
    var participated: [(user: User, amount:Double)] = []
    
    init(name: String, notes: String, creator: User, money: Double) {
        self.name = name
        self.notes = notes
        self.creator = creator
        self.moneyPayed = money
    }
    
    init(name: String, creator: User, money: Double, notes: String?) {
        self.name = name
        self.creator = creator
        self.moneyPayed = money
        if let n = notes {
            self.notes = n
        }
    }
    
    func hasPayed(user: User) -> Bool {
        for payment in payed {
            if payment.user.isSame(user) {
                return true
            }
        }
        return false
    }
    func hasParticipated(user: User) -> Bool {
        for payment in participated {
            if payment.user.isSame(user) {
                return true
            }
        }
        return false
    }
}
