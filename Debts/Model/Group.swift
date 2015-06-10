//
//  Group.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftyJSON

class Group: NSObject {
    var gID:String = ""
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
    
    /*init(details: JSON) {
        self.phoneNumber = details["phone"].stringValue
        self.firstname = details["firstname"].stringValue
        self.lastname = details["lastname"].stringValue
        self.uid = details["_id"].stringValue
    }*/
    
    init(details: JSON) {
        self.gID = details["_id"].stringValue
        self.name = details["name"].stringValue
        self.total = details["total"].doubleValue
        
        var created = details["created"].stringValue
        println("Timestamp: \(created)")
        
        if let userArray = details["users"].array {
            for user in userArray {
                var u:User = User(details: user)
                self.users.append(u)
            }
        }
        
        self.creator = User(details: details["creator"])
        
        if let transferArray = details["transfers"].array {
            for transfer in transferArray {
                var t:MoneyTransfer = MoneyTransfer(details: transfer)
                self.transfers.append(t)
            }
        }
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
    
    func getTotalFinanceForUser(user:User) -> Double {
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
        return (userHasPayed+userHasToPay).roundToMoney()
    }
    
    func calculateAccounts() -> [(user: User, action: String, amount: Double, partner: User)] {
        var accounts:[(user: User, action: String, amount: Double, partner: User)] = []
        
        var pays:[(user: User, amount:Double)] = []
        var gets:[(user: User, amount:Double)] = []
        for user in users {
            var amount = getTotalFinanceForUser(user)
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
        
        var moneyLeftToPay = true
        
        while moneyLeftToPay {
            var getAmount = (gets[0].amount).roundToMoney()
            var payAmount = (pays[0].amount).roundToMoney()
            if getAmount == payAmount {
                println("\(pays[0].user.firstname) pays \(payAmount)€ to \(gets[0].user.firstname)")
                accounts += [(user: pays[0].user, action: "pay", amount: payAmount, partner: gets[0].user)]
                accounts += [(user: gets[0].user, action: "get", amount: payAmount, partner: pays[0].user)]
                
                getAmount = 0.0
                payAmount = 0.0
            } else if getAmount > payAmount {
                println("\(pays[0].user.firstname) pays \(payAmount)€ to \(gets[0].user.firstname)")
                accounts += [(user: pays[0].user, action: "pay", amount: payAmount, partner: gets[0].user)]
                accounts += [(user: gets[0].user, action: "get", amount: payAmount, partner: pays[0].user)]
                
                getAmount -= payAmount
                payAmount = 0.0
            } else if getAmount < payAmount {
                println("\(pays[0].user.firstname) pays \(getAmount)€ to \(gets[0].user.firstname)")
                accounts += [(user: pays[0].user, action: "pay", amount: getAmount, partner: gets[0].user)]
                accounts += [(user: gets[0].user, action: "get", amount: getAmount, partner: pays[0].user)]
                
                payAmount -= getAmount
                getAmount = 0.0
            }
            // but new amounts back to list and sort to compare the highest values
            gets[0].amount = getAmount
            pays[0].amount = payAmount
            pays.sort({ $0.amount > $1.amount })
            gets.sort({ $0.amount > $1.amount })
            if gets[0].amount == 0.0 && pays[0].amount == 0.0 {
                moneyLeftToPay = false
            } else if gets[0].amount < 0.01 || pays[0].amount < 0.01 {
                // rounding error appeared
                // should never happen anymore
                println("GETS:")
                println(gets[0].amount)
                println("PAYS:")
                println(pays[0].amount)
                moneyLeftToPay = false
            }
        }
        return accounts
    }

    func getAccountForUser(user: User) -> [(user: User, action: String, amount: Double, partner: User)] {
        var allAccounts = calculateAccounts()
        var userAccounts: [(user: User, action: String, amount: Double, partner: User)] = []
        for account in allAccounts {
            if account.user.isSame(user) {
                userAccounts.append(account)
            }
        }
        return userAccounts
    }
}