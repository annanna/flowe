//
//  MoneyTransfer.swift
//  
//
//  Created by Anna on 25.04.15.
//
//

import UIKit
import SwiftyJSON

class MoneyTransfer: NSObject {
    var tID = ""
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
        self.moneyPayed = money.roundToMoney()
    }
    
    init(name: String, creator: User, money: Double, notes: String?) {
        self.name = name
        self.creator = creator
        self.moneyPayed = money.roundToMoney()
        if let n = notes {
            self.notes = n
        }
    }
    
    init(details: JSON) {
        self.tID = details["_id"].stringValue
        self.name = details["name"].stringValue
        var created = details["created"].stringValue
        println("Timestamp: \(created)")
        let creatorId = details["creator"].stringValue
        if let cre = UserHelper.getUser(creatorId) {
            self.creator = cre
        } else {
            println("don't know this user")
            self.creator = User(rand: 1)
        }
        
        self.notes = details["notes"].stringValue
        self.moneyPayed = details["total"].doubleValue
        
        if let whoPayedArray = details["whoPayed"].array {
            for pay in whoPayedArray {
                var userId = pay["user"].stringValue
                if let u = UserHelper.getUser(userId) {
                    var a:Double = pay["amount"].doubleValue
                    payed += [(user:u, amount:a)]
                }
            }
        }
        
        if let whoTookPartArray = details["whoTookPart"].array {
            for part in whoTookPartArray {
                var userId = part["user"].stringValue
                if let u = UserHelper.getUser(userId) {
                    var a:Double = part["amount"].doubleValue
                    participated += [(user:u, amount:a)]
                }
            }
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