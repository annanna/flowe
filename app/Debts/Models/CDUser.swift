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

@objc(CDUser)
class CDUser: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var phoneNumber: String
    @NSManaged var id: String
    
    static let entityName = "User"

    func loadFromJSON (details: JSON, callback:(Void)->Void) {
        self.phoneNumber = details["phone"].stringValue
        self.firstname = details["firstname"].stringValue
        self.lastname = details["lastname"].stringValue
        self.id = details["_id"].stringValue
        callback()
    }
    /*
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
    
    func isSame(user:CDUser) -> Bool {
        if user.id == self.id {
            return true
        }
        return false
    }*/
    
    static func findOrCreateUser(details: JSON, inContext context:NSManagedObjectContext, callback:(CDUser)->Void) {
        let identifier = details["_id"].stringValue
        var fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", identifier)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let user = objects[0] as? CDUser {
                    println("existing user \(user.firstname)")
                    callback(user)
                }
            } else {
                if let newUser = NSEntityDescription.insertNewObjectForEntityForName(self.entityName, inManagedObjectContext:context) as? CDUser {
                    newUser.loadFromJSON(details, callback: { () -> Void in
                        println("new user \(newUser.firstname)")
                        callback(newUser)
                    })
                }
            }
        }
    }
    
    static func findUserIfExists(predicate: NSPredicate, context: NSManagedObjectContext) -> CDUser? {
        var fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.predicate = predicate
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let user = objects[0] as? CDUser {
                    println("user fetched")
                    return user
                }
            }
        }
        return nil
    }
    
    func asDictionary() -> [String: String] {
        return [
            "_id": self.id,
            "phone": self.phoneNumber,
            "firstname": self.firstname,
            "lastname": self.lastname
        ]
    }
}
