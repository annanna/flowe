//
//  Users.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftAddressBook

class User: NSObject {
    var uID: String = ""
    var phoneNumber:String //works as primary key for now -> what if changed?
    var firstname = ""
    var lastname = ""
    var email = ""
    var img: UIImage?
    
    init(coreDataUser: CDUser) {
        self.uID = coreDataUser.id
        self.phoneNumber = coreDataUser.phoneNumber
        self.firstname = coreDataUser.firstname
        self.lastname = coreDataUser.lastname
       // self.email = coreDataUser.email
    }
    
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
            case 2: first = "Daniel"; last = "Higgins"; phone = "555-478-7672"
            case 3: first = "John"; last = "Appleseed"; phone = "888-555-5512"
            case 4: first = "Anna"; last = "Haro"; phone = "555-522-8243"
            case 5: first = "David"; last = "Taylor"; phone = "555-610-6679"
            case 6: first = "Hank"; last = "Zakroff"; phone = "(555) 766-4823"
            case 7: first = "Papa"; last = "Pau"
            case 8: first = "Lutz"; last = "Leber"
            case 9: first = "Trude"; last = "Taube"
            default: first = "Heinz"; last = "Ketchup"
        }
        self.phoneNumber = phone
        self.firstname = first
        self.lastname = last
    }
    
    init(details: JSON) {
        self.phoneNumber = details["phone"].stringValue
        self.firstname = details["firstname"].stringValue
        self.lastname = details["lastname"].stringValue
        self.uID = details["_id"].stringValue
    }
    
    init(person: SwiftAddressBookPerson) {
        if let phone = person.phoneNumbers {
            self.phoneNumber = phone[0].value
        } else {
            self.phoneNumber = ""
        }
        if let first = person.firstName {
            self.firstname = first
        }
        if let last = person.lastName {
            self.lastname = last
        }
        if let emails = person.emails {
            self.email = emails[0].value
        }
        if person.hasImageData() {
            self.img = person.image!
        }
    }
    
    func getInitials() -> String {
        var initials = ""
        if self.firstname.characters.count > 0 {
            initials += "\(Array(self.firstname.characters)[0])"
        }
        if self.lastname.characters.count > 0 {
            initials += "\(Array(self.lastname.characters)[0])"
        }
        
        return initials
    }
    func getName() -> String {
        return "\(self.firstname) \(self.lastname)"
    }
    
    func isSame(user:User) -> Bool {
        if user.uID == self.uID {
            return true
        }
        return false
    }
    
    func updateUser(details: JSON) {
        self.phoneNumber = details["phone"].stringValue
        self.firstname = details["firstname"].stringValue
        self.lastname = details["lastname"].stringValue
    }
    
    func asDictionary() -> [String: String] {
        return [
            "phone": self.phoneNumber,
            "firstname": self.firstname,
            "lastname": self.lastname
        ]
    }
}
