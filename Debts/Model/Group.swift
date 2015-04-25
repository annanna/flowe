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
    var sum = -40 //fixed value for now
    
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
    
}
