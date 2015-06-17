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
    var transfers = [MoneyTransfer]()
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
        
        self.total = details["personalTotal"].doubleValue
        self.creator = UserHelper.JSONcreateUserIfDoesNotExist(details["creator"])
        
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
    
    func updateTotal(transfer: MoneyTransfer) {
        var userHasToPay = 0.0
        var userHasPayed = 0.0
        
        var whoPayed = transfer.payed
        for pay in whoPayed {
            if pay.user.uID == GlobalVar.currentUid {
                userHasPayed += pay.amount
            }
        }
        for part in transfer.participated {
            if part.user.uID == GlobalVar.currentUid {
                userHasToPay += part.amount
            }
        }
        self.total = (userHasPayed - userHasToPay).roundToMoney()
    }
    
}