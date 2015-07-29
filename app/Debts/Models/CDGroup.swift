//
//  Group.swift
//  Debts
//
//  Created by Anna on 25.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(CDGroup)
class CDGroup: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var created: NSDate
    @NSManaged var name: String
    @NSManaged var total: NSNumber
    @NSManaged var creator: CDUser
    @NSManaged var expenses: NSSet
    @NSManaged var users: NSSet // [CDUser]
    @NSManaged var accounts: NSSet // [CDAccount]
    
    static let entityName = "Group"
    
    /*
    func getUsers() -> [User] {
        if let userArray = self.users.allObjects as? [User] {
            return userArray
        }
        return [User]()
    }
    func getExpenses() -> [Expense] {
        if let expArray = self.expenses.allObjects as? [Expense] {
            return expArray
        }
        return [Expense]()
    }
    func getAccounts() -> [Account] {
        if let accArray = self.accounts.allObjects as? [Account] {
            return accArray
        }
        return [Account]()
    }
    
    func hasUser(user:User) -> Bool {
        if let userArray = self.users.allObjects as? [User] {
            for u in userArray {
                if u.isSame(user) {
                    return true
                }
            }
        }
        return false
    }

    func updateTotal(expense: Expense) {
        var userHasToPay = 0.0
        var userHasPayed = 0.0
        
        var whoPayed = expense.payed
        for pay in whoPayed {
            if pay.user.id == GlobalVar.currentUid {
                userHasPayed += pay.amount
            }
        }
        for part in expense.participated {
            if part.user.id == GlobalVar.currentUid {
                userHasToPay += part.amount
            }
        }
        self.total = (userHasPayed - userHasToPay).roundToMoney()
    }
    */
    func addUser(user: User) {
        var userArr = self.users.allObjects as! [CDUser]
//        userArr.append(user)
        self.users = NSSet(array: userArr)
    }
    
    func loadFromJSON(details: JSON, callback: (Void)->Void) {
        
        self.id = details["_id"].stringValue
        self.name = details["name"].stringValue
        var created = details["created"].stringValue
        //println("Timestamp: \(created)")
        
        
        if let userArray = details["users"].array {
            var userCount = userArray.count
            for user in userArray {
                var userDic = JSONHelper.JSONObjToStringDic(user)
                RequestHelper.getUserDetails(userDic, byId: true, callback: { (user) -> Void in
                    self.addUser(user)
                    userCount -= 1
                    if userCount == 0 {
                        callback()
                    }
                })
            }
        }
        
        self.total = details["personalTotal"].doubleValue
        let creatorId = details["creator"].stringValue
    }
    static func findOrCreateGroup(details: JSON, inContext context:NSManagedObjectContext, callback:((group: CDGroup)->Void)) {
        let groupId = details["_id"].stringValue
        var fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", groupId)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let existingGroup = objects[0] as? CDGroup {
                    // update group -> TODO: check if modified
                    existingGroup.loadFromJSON(details, callback: { () -> Void in
                        println("existing group \(existingGroup.name)")
                        callback(group: existingGroup)
                    })
                }
            } else {
                if let newGroup = NSEntityDescription.insertNewObjectForEntityForName(self.entityName, inManagedObjectContext:context) as? CDGroup {
                    newGroup.loadFromJSON(details, callback: { () -> Void in
                        println("new group \(newGroup.name)")
                        callback(group: newGroup)
                    })
                }
            }
        }
    }
    
    static func findGroupsWithUser(context: NSManagedObjectContext, callback:([CDGroup])->Void) {
        
        var fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "users CONTAINS %@", GlobalVar.currentUser)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let fetchedGroups = objects as? [CDGroup] {
                    callback(fetchedGroups)
                }
            }
            
        }
    }
}