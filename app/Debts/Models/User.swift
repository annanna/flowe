//
//  User.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import SwiftAddressBook

@objc(User)
class User: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var phoneNumber: String
    @NSManaged var uID: String
    
    
    
    func loadFromJSON (details: JSON) {
        println("user init")
        self.phoneNumber = details["phone"].stringValue
        self.firstname = details["firstname"].stringValue
        self.lastname = details["lastname"].stringValue
        self.uID = details["_id"].stringValue
    }
    
    func loadFromAddressBook (person: SwiftAddressBookPerson) {
        if let phone = person.phoneNumbers {
            let num = phone[0].value
            println("\(num)")
            self.phoneNumber = num
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
        }/*
        if person.hasImageData() {
        self.img = person.image!
        }*/
    }
    
    func getName() -> String {
        var initials = ""
        if count(self.firstname) > 0 {
            initials += "\(Array(self.firstname)[0])"
        }
        if count(self.lastname) > 0 {
            initials += "\(Array(self.lastname)[0])"
        }
        
        return initials
    }
    
    func isSame(user:User) -> Bool {
        if user.uID == self.uID {
            return true
        }
        return false
    }
    /*
    func updateUser(details: JSON) {
    self.phoneNumber = details["phone"].stringValue
    self.firstname = details["firstname"].stringValue
    self.lastname = details["lastname"].stringValue
    }*/
    
    
    static func findOrCreateUser(details: JSON, inContext context:NSManagedObjectContext) -> User {
        let identifier = details["_id"].stringValue
        var fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "uID = %@", identifier)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let user = objects[0] as? User {
                    println("user fetched")
                    return user
                }
            }
            if let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext:context) as? User {
                println("created user")
                newUser.loadFromJSON(details)
                return newUser
            }
        }
        println("could not fetch or create user...")
        return User()
    }
    
    static func findOrCreateAddressBookUser(details: SwiftAddressBookPerson, inContext context:NSManagedObjectContext) -> User {
        
        let phone = details.phoneNumbers!
        let identifier = phone[0].value
        println(identifier)
        
        var fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "phoneNumber = %@", identifier)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let user = objects[0] as? User {
                    println("user fetched")
                    return user
                }
            }
            if let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext:context) as? User {
                println("created user")
                newUser.loadFromAddressBook(details)
                return newUser
            }
        }
        println("could not fetch or create user...")
        return User()
    }
    
    static func findOrCreateUserById(identifier: String, inContext context:NSManagedObjectContext) -> User {
        var fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "uID = %@", identifier)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let user = objects[0] as? User {
                    println("user fetched")
                    return user
                }
            }
            if let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext:context) as? User {
                newUser.uID = identifier
                println("created user")
                return newUser
            }
        }
        println("could not fetch or create user...")
        return User()
    }

}
