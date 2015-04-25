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
    var imageLink = ""
    var participants: [UsersInTransfers] = []
    
    init(name: String, notes: String, creator: User, participants: [UsersInTransfers]) {
        self.name = name
        self.notes = notes
        self.creator = creator
        self.participants = participants
    }
}
