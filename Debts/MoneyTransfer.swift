//
//  MoneyTransfer.swift
//  
//
//  Created by Anna on 25.04.15.
//
//

import UIKit

class MoneyTransfer: NSObject {
    var inGroup: Group
    var timestamp = NSDate()
    var notes = ""
    var creator: User
    var imageLink = ""
    var participants: [UsersInTransfers] = []
    
    init(group: Group, notes: String, creator: User, participants: [UsersInTransfers]) {
        self.inGroup = group
        self.notes = notes
        self.creator = creator
        self.participants = participants
    }
}
