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
    var paymentAmount: Double
    var participationAmount: Bool
    
    init(user: User, payment: Double, participation: Bool) {
        self.user = user
        self.paymentAmount = payment
        self.participationAmount = participation
    }
}
