//
//  Users.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class User: NSObject {
    var firstname = ""
    var lastname = ""
    var email = ""
    var img: UIImage?
    
    init(first: String, last: String) {
        self.firstname = first
        self.lastname = last
    }
    
    init(rand: Int) {
        var first = ""
        var last = ""
        switch rand {
            case 1: first = "Agatha"; last = "Malibu"
            case 2: first = "Bob"; last = "Berlin"
            case 3: first = "Bernd"; last = "Brot"
            case 4: first = "Dora"; last = "Dresden"
            case 5: first = "Ernst"; last = "Ente"
            case 6: first = "Mama"; last = "Minute"
            case 7: first = "Papa"; last = "Pau"
            case 8: first = "Lutz"; last = "Leber"
            case 9: first = "Trude"; last = "Taube"
            default: first = "Heinz"; last = "Ketchup"
        }
        self.firstname = first
        self.lastname = last
    }
    
    func getName() -> String {
        return "\(Array(self.firstname)[0])\(Array(self.lastname)[0])"
    }
}
