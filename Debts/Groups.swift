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
   
}
