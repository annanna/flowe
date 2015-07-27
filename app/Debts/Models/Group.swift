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

@objc(Group)
class Group: NSManagedObject {

    @NSManaged var gID: String
    @NSManaged var created: NSDate
    @NSManaged var name: String
    @NSManaged var total: NSNumber
    @NSManaged var creator: User
    @NSManaged var expenses: NSSet
    @NSManaged var users: NSSet
    @NSManaged var accounts: NSSet
    
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
            if pay.user.uID == GlobalVar.currentUid {
                userHasPayed += pay.amount
            }
        }
        for part in expense.participated {
            if part.user.uID == GlobalVar.currentUid {
                userHasToPay += part.amount
            }
        }
        self.total = (userHasPayed - userHasToPay).roundToMoney()
    }
    
    func loadFromJSON(details: JSON) {
        
        self.gID = details["_id"].stringValue
        self.name = details["name"].stringValue
        var created = details["created"].stringValue
        //println("Timestamp: \(created)")
        
        /*if let userArray = details["users"].array {
            for user in userArray {
                var u:User = UserHelper.JSONcreateUserIfDoesNotExist(user)
                var userArr = self.users.allObjects as! [User]
                userArr.append(u)
                self.users = NSSet(array: userArr)
            }
        }*/
        
        self.total = details["personalTotal"].doubleValue
        /*self.creator = UserHelper.JSONcreateUserIfDoesNotExist(details["creator"])*/
        /*
        if let expenseArray = details["expenses"].array {
            for transfer in expenseArray {
                var t:Expense = Expense(details: transfer)
                var expenseArr = self.expenses.allObjects as! [Expense]
                expenseArr.append(t)
                self.expenses = NSSet(array: expenseArr)
            }
        }*/
    }
    
    static func findOrCreateGroup(details: JSON, inContext context:NSManagedObjectContext) -> Group {
        let identifier = details["_id"].stringValue
        var fetchRequest = NSFetchRequest(entityName: "Group")
        fetchRequest.predicate = NSPredicate(format: "gID = %@", identifier)
        var error:NSError? = nil
        
        var result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("error \(error?.localizedDescription)")
        }
        if let objects = result {
            if objects.count > 0 {
                if let group = objects[0] as? Group {
                    println("group fetched")
                    return group
                }
            }
            if let newGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext:context) as? Group {
                println("created group")
                newGroup.loadFromJSON(details)
                return newGroup
            }
        }
        println("could not fetch or create group...")
        return Group()
    }
}