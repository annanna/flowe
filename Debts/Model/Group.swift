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
        var userHasToPay = 0.0
        var userHasPayed = 0.0
        for transfer in transfers {
            for payment in transfer.payed {
                if payment.user.isSame(user) {
                    userHasPayed += payment.amount
                }
            }
            for payment in transfer.participated {
                if payment.user.isSame(user) {
                    userHasToPay -= payment.amount
                }
            }
        }
        return round((userHasPayed+userHasToPay) * 100) / 100
    }
    
    func calculateAccounts() {
        var pays:[(user: User, amount:Double)] = []
        var gets:[(user: User, amount:Double)] = []
        for user in users {
            var amount = getFinanceForUser(user)
            if amount > 0 {
                gets += [(user:user,amount:amount)]
            } else if amount < 0 {
                amount *= -1
                pays += [(user:user,amount:amount)]
            }
        }
        pays.sort({ $0.amount > $1.amount })
        gets.sort({ $0.amount > $1.amount })
        
        var cnt = pays.count
        if gets.count < pays.count {
            cnt = gets.count
        }
        
        var getLooping = true
        var i = 0
        
        while getLooping {
            if gets[i].amount == pays[i].amount {
                println("\(pays[i].user.firstname) pays \(pays[i].amount)€ to \(gets[i].user.firstname)")
                gets[i].amount = 0.0
                pays[i].amount = 0.0
            } else if gets[i].amount > pays[i].amount {
                println("\(pays[i].user.firstname) pays \(pays[i].amount)€ to \(gets[i].user.firstname)")
                gets[i].amount -= pays[i].amount
                pays[i].amount = 0.0
            } else if gets[i].amount < pays[i].amount {
                println("\(pays[i].user.firstname) pays \(gets[i].amount)€ to \(gets[i].user.firstname)")
                pays[i].amount -= gets[i].amount
                gets[i].amount = 0.0
            }
            pays.sort({ $0.amount > $1.amount })
            gets.sort({ $0.amount > $1.amount })
            if gets[i].amount == 0.0 && pays[i].amount == 0 {
                getLooping = false
            }
        }
    }
}