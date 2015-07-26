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
    var users = [User]()
    var creator: User?
    var expenses = [Expense]()
    var total = 0.0
    
    init(name: String, users: [User], creator: User) {
        self.name = name
        self.users = users
        self.creator = creator
    }
    
    init(details: JSON) {
        println("group init")
        self.gID = details["_id"].stringValue
        self.name = details["name"].stringValue
        var created = details["created"].stringValue
        //println("Timestamp: \(created)")
        
        if let userArray = details["users"].array {
            for user in userArray {
                var u:User = UserHelper.JSONcreateUserIfDoesNotExist(user)
                self.users.append(u)
            }
        }
        
        self.total = details["personalSaldo"].doubleValue
        self.creator = UserHelper.JSONcreateUserIfDoesNotExist(details["creator"])
        
        if let expenseArray = details["expenses"].array {
            for transfer in expenseArray {
                var t:Expense = Expense(details: transfer)
                self.expenses.append(t)
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
        for expense in expenses {
            total -= expense.moneyPayed
        }
        self.total = total
    }
    
    func addTransfer(transfer: Expense) {
        self.expenses.append(transfer)
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
    
    func updateTotal(expense: Expense) {
        var userHasToPay = 0.0
        var userHasPayed = 0.0
        
        var whoPayed = expense.payed
        for pay in whoPayed {
            if GlobalVar.currentUser.isSame(pay.user) {
                userHasPayed += pay.amount
            }
        }
        for part in expense.participated {
            if GlobalVar.currentUser.isSame(part.user) {
                userHasToPay += part.amount
            }
        }
        self.total = (userHasPayed - userHasToPay).roundToMoney()
    }
    
}