//
//  Users.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class User: NSObject {
    var phoneNumber:String //works as primary key for now -> what if changed?
    var firstname = ""
    var lastname = ""
    var email = ""
    var img: UIImage?
    
    init(phone: String) {
        self.phoneNumber = phone
    }
    
    init(phone: String, first: String, last: String) {
        self.phoneNumber = phone
        self.firstname = first
        self.lastname = last
    }
    
    init(rand: Int) {
        var phone = "123456789"
        var first = ""
        var last = ""
        switch rand {
            case 1: first = "Kate"; last = "Bell"; phone = "(555) 564-8583"
            case 2: first = "Daniel"; last = "Higgins"; phone = "123456789"
            case 3: first = "John"; last = "Appleseed"; phone = "777878787"
            case 4: first = "Dora"; last = "Dresden"
            case 5: first = "Ernst"; last = "Ente"
            case 6: first = "Mama"; last = "Minute"
            case 7: first = "Papa"; last = "Pau"
            case 8: first = "Lutz"; last = "Leber"
            case 9: first = "Trude"; last = "Taube"
            default: first = "Heinz"; last = "Ketchup"
        }
        self.phoneNumber = phone
        self.firstname = first
        self.lastname = last
    }
    
    func getName() -> String {
        return "\(Array(self.firstname)[0])\(Array(self.lastname)[0])"
    }
    
    func isSame(user:User) -> Bool {
        if user.phoneNumber == self.phoneNumber {
            return true
        }
        return false
    }
    
}
