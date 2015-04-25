//
//  UsersInTransfers.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class UsersInTransfers: NSObject {
    var user: User
    var paymentAmount = 0
    var participationAmount = 0
    
    init(user: User, payment: Int, participation: Int) {
        self.user = user
        self.paymentAmount = payment
        self.participationAmount = participation
    }
}
