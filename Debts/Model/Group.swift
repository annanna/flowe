//
//  Group.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class Group: NSObject {
    var name = ""
    var created = NSDate()
    var users: [User] = []
    var creator: User
    var transfers: [MoneyTransfer] = []
    var total = 0.0
    
    init(name: String, users: [User], creator: User) {
        self.name = name
        self.users = users
        self.creator = creator
    }
    
    func getUsers() -> String {
        var initials = ""
        for user in self.users {
            initials += user.getName() + " "
        }
        return initials
    }
    
    func setTotal() {
        var total = 0.0
        for transfer in transfers {
            total -= transfer.moneyPayed
        }
        self.total = total
    }
    
    func addTransfer(transfer: MoneyTransfer) {
        self.transfers.append(transfer)
        setTotal()
    }
    
    func hasUser(user:User) -> Bool {
        for u in users {
            if u.isSame(user) {
                return true
            }
        }
        return false
    }
    
    func getFinanceForUser(user:User) -> Double {
        var everyMemberHasToPay:Double = total / Double(users.count)
        var userHasPayed = 0.0
        for transfer in transfers {
            for payment in transfer.payed {
                if payment.user.isSame(user) {
                    userHasPayed += payment.amount
                }
            }
        }
        return round((everyMemberHasToPay+userHasPayed) * 100) / 100
    }
}