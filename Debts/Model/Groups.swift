//
//  Groups.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class Groups: NSObject {
    var groups: [Group] = []
    
    
    func addGroup(group: Group) {
        groups.append(group)
    }
    
    func getGroupsOfUser(user: User)->[Group] {
        var userGroups: [Group] = []
        for group in groups {
            if group.hasUser(user) {
                userGroups.append(group)
            }
        }
        return userGroups
    }
}
