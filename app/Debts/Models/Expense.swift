//
//  Expense.swift
//  
//
//  Created by Anna on 25.04.15.
//
//

import UIKit
import SwiftyJSON

class Expense : NSObject {
    var eID = ""
    var name = ""
    var timestamp = NSDate()
    var notes = ""
    var creator = GlobalVar.currentUser
    var moneyPayed = 0.0
    var imageLink = ""
    
    var payed: [(user: User, amount:Double)] = []
    var participated: [(user: User, amount:Double)] = []
    
    /*init(name: String, notes: String, creator: User, money: Double) {
        self.name = name
        self.notes = notes
        self.creator = creator
        self.moneyPayed = money.roundToMoney()
    }*/
    
    init(name: String, creator: User, money: Double, notes: String?) {
        self.name = name
        self.creator = creator
        self.moneyPayed = money.roundToMoney()
        if let n = notes {
            self.notes = n
        }
    }
    
    init(details: JSON) {
        self.eID = details["_id"].stringValue
        self.name = details["name"].stringValue
        _ = details["created"].stringValue
        //println("Timestamp: \(created)")
        
        self.notes = details["notes"].stringValue
        self.moneyPayed = details["total"].doubleValue
        super.init()
        if let whoPayedArray = details["whoPayed"].array {
            for (_,pay) in whoPayedArray.enumerate() {
                let payerId = pay["user"].stringValue
                
                UserHelper.getUserById(payerId, callback: { (user) -> Void in
                    let a:Double = pay["amount"].doubleValue
                    self.payed += [(user:user, amount:a)]
                })
            }
        }
        
        if let whoTookPartArray = details["whoTookPart"].array {
            for (_,part) in whoTookPartArray.enumerate() {
                let partId = part["user"].stringValue
                
                UserHelper.getUserById(partId, callback: { (user) -> Void in
                    let a:Double = part["amount"].doubleValue
                    self.participated += [(user:user, amount:a)]
                })
            }
        }
        
        let creatorId = details["creator"].stringValue
        UserHelper.getUserById(creatorId, callback: { (creator) -> Void in
            self.creator = creator
        })
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
    
    func generateConclusion() -> String {
        if self.payed.count > 0 {
            
            let firstUser = self.payed[0].user
            var label = firstUser.firstname
            var verb = " hat "
            if firstUser.uID == GlobalVar.currentUid {
                label = "Du"
                verb = " hast "
            }
            let usersLeft = self.payed.count-1
            var count = 1
            
            
            var joiner = ""
            if usersLeft > 0 {
                joiner = ", "
                verb = " haben "
                
                for (user, _) in self.payed[1...usersLeft] {
                    if count == usersLeft {
                        joiner = " und "
                    }
                    if user.uID == GlobalVar.currentUid {
                        label += joiner + "du"
                    } else {
                        label += joiner + user.firstname
                    }
                    count += 1
                }
            }
            label += verb
            label += "\(self.moneyPayed.toMoneyString()) für \(self.name) bezahlt"
            return label
        }
        return ""
    }
    
    func asDictionary() -> [String: AnyObject] {
        var whoPayed = [[String: AnyObject]]()
        for (user, amount) in self.payed {
            let payed:[String: AnyObject] = [
                "user": user.uID,
                "amount": amount
            ]
            whoPayed.append(payed)
        }
        var whoTookPart = [[String: AnyObject]]()
        for (user, amount) in self.participated {
            let participated:[String: AnyObject] = [
                "user": user.uID,
                "amount": amount
            ]
            whoTookPart.append(participated)
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy HH:mm"
        let expenseDate = dateFormatter.stringFromDate(self.timestamp)
        
        return [
            "name": self.name,
            "creator": GlobalVar.currentUid,
            "timestamp": expenseDate,
            "total": self.moneyPayed,
            "notes": self.notes,
            "whoTookPart": whoTookPart,
            "whoPayed": whoPayed
        ]
    }
}