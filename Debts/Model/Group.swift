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
    
    init(name: String, users: [User], creator: User) {
        self.name = name
        self.users = users
        self.creator = creator
    }
    
    func getUsers() -> String {
        var initials = ""
        for user in self.users {
            var initial = "\(Array(user.firstname)[0])\(Array(user.lastname)[0])"
            initials += initial + " "
        }
        return initials
    }
    
}
