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
    var userPayed: User
    var moneyPayed = 0.0
    var imageLink = ""
    var participants: [UsersInTransfers] = []
    
    init(name: String, notes: String, creator: User, money: Double, participants: [UsersInTransfers]) {
        self.name = name
        self.notes = notes
        self.userPayed = creator
        self.moneyPayed = money
        self.participants = participants
    }
    
    init(name: String, creator: User, money: Double, notes: String?) {
        self.name = name
        self.userPayed = creator
        self.moneyPayed = money
        if let n = notes {
            self.notes = n
        }
    }

    func addUsersInTransfers(users: [User]) {
        var usersInTransfers = []
        var payment = self.moneyPayed / Double(usersInTransfers.count)
        for user in users {
            var trUser = UsersInTransfers(user: user, payment: payment, participation: true)
            participants.append(trUser)
        }
    }
    
}
