//
//  RequestHelper.swift
//  Debts
//
//  Created by Anna on 05.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class RequestHelper {
    
    static let dataUrl = "https://flowe.herokuapp.com"
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let context = appDelegate.managedObjectContext
    
    //  /users
    class func getUserDetails(user: [String: String], byId: Bool, callback:(User) -> Void) {
        var predicate:NSPredicate?
        var val = ""
        if byId {
            val = user["_id"] as String!
            predicate = NSPredicate(format: "id = %@", val)
        } else {
            val = user["phone"] as String!
            predicate = NSPredicate(format: "phoneNumber = %@", val)
        }
        
        if let coreDataUser = CDUser.findUserIfExists(predicate!, context: self.context!) {
            // user found in local Core Data db
            let fetchedUser = User(coreDataUser: coreDataUser)
            UserHelper.createUserIfDoesNotExist(fetchedUser)
            callback(fetchedUser)
        } else if !GlobalVar.offline {
            // look for user on server
            var url = "\(dataUrl)/users?"
            if byId {
                url += "uid=\(val)"
            } else {
                let customAllowedSet =  NSCharacterSet(charactersInString:"+() \"#%/<>?@\\^`{|}").invertedSet
                let escapedPhone = val.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet) as String!
                url += "phone=\(escapedPhone)"
            }
            
            Alamofire.request(.GET, url)
                .responseJSON {
                    (request, response, jsonResponse, error) in
                    if (error != nil) {
                        println("Error getting user \(error)")
                        println(request)
                        println(response)
                    } else {
                        if let jsonData: AnyObject = jsonResponse {
                            let userData = JSON(jsonData)
                            // save user in Core Data and UserHelper-Dic
                            self.saveUser(userData, callback: callback)
                        } else {
                            println("user does not exist on server")
                            self.createUser(user, callback: callback)
                        }
                    }
            }
        } else {
            self.appDelegate.showError()
        }
    }
    class func getCDUser(id: String, callback:(CDUser)->Void) {
        if let coreDataUser = CDUser.findUserIfExists(NSPredicate(format: "id = %@", id), context: self.context!) {
            // user found in local Core Data db
            callback(coreDataUser)
        }
    }
    
    private class func createUser(user: [String: String], callback:(User) -> Void) {
        let url = "\(dataUrl)/users"
        Alamofire.request(.POST, url, parameters: user)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if let jsonData: AnyObject = jsonResponse {
                    let userData = JSON(jsonData)
                    self.saveUser(userData, callback: callback)
                }
        }
    }
    private class func saveUser(userData: JSON, callback:(User)->Void) {
        // store user in local db
        CDUser.findOrCreateUser(userData, inContext: self.context!) { (user) -> Void in
            self.appDelegate.saveContext()
            // store user in UserHelper-Dic
            let newUser = User(coreDataUser: user)
            UserHelper.createUserIfDoesNotExist(newUser)
            callback(newUser)
        }
    }
    

    //  /:uid/groups
    class func getGroups(callback:([Group]) -> Void) {
        
        if GlobalVar.offline {
            CDGroup.findGroupsWithUser(self.context!, callback: { (cdGroups) -> Void in
                callback(self.transformGroups(cdGroups))
            })
        } else {
            
            let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/"
            Alamofire.request(.GET, url)
                .responseJSON {
                    (request, response, jsonResponse, error) in
                    if(error != nil) {
                        println("Error fetching groups: \(error)")
                        println(request)
                        println(response)
                    } else {
                        if let jsonData: AnyObject = jsonResponse {
                            let json = JSON(jsonData)
                            if let groupArray = json.array {
                                let cdGroupCount = groupArray.count
                                var groups = [Group]()
                                
                                for group in groupArray {
                                    groups.append(Group(details: group))
                                    callback(groups)

                                    CDGroup.findOrCreateGroup(group, inContext: self.context!, callback: { (newGroup:CDGroup) -> Void in
                                        self.appDelegate.saveContext()
                                        
                                        if groups.count == cdGroupCount {
                                            println("Successfully saved \(groups.count) groups in Core Data")
                                        }
                                    })
                                }
                            }
                        }
                    }
            }
        }
    }
    class func postGroup(name: String, users: [User], callback:(Group) -> Void) {
        let url =  "\(dataUrl)/\(GlobalVar.currentUid)/groups"
        
        var users = JSONHelper.createDictionaryFromUsers(users)
        
        let postBody:[String: AnyObject] = [
            "name": name,
            "users": users,
            "creator": GlobalVar.currentUid
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postBody, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        Alamofire.request(request)
            .responseJSON(completionHandler: { (request, response, jsonResponse, error) -> Void in
                if(error != nil) {
                    println("Error creating group \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let json = JSON(jsonData)
                        self.saveGroupInCoreData(json, callback: callback)
                    }
                }
            })
    }
    
    private class func transformGroups(cdGroups: [CDGroup]) -> [Group] {
        var groups = [Group]()
        for gr in cdGroups {
            let group = Group(coreDataGroup: gr)
            groups.append(group)
        }
        return groups
    }
    //  /:uid/groups/:groupId
    class func getGroupDetails(groupId: String, callback:(Group)->Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if(error != nil) {
                    println("Error fetching group \(groupId) \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let groupData = JSON(jsonData)
                        callback(Group(details: groupData))
                        self.saveGroupInCoreData(groupData, callback: callback)
                        println("Successfully fetched group \(groupId)")
                    }
                }
        }
    }
    
    private class func saveGroupInCoreData(groupData: JSON, callback:(Group)->Void) {
        // store group in local db
        CDGroup.findOrCreateGroup(groupData, inContext: self.context!) { (group) -> Void in
            self.appDelegate.saveContext()
//            callback(Group(coreDataGroup: group))
        }
    }
    
    //  /:uid/groups/:groupId/expenses
    class func createExpense(groupId: String, expense: Expense, callback:(Expense) -> Void) {
        
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/expenses"
        
        var postBody: [String: AnyObject] = expense.asDictionary()
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postBody, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        Alamofire.request(request)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error creating expense \(expense.name)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let expenseData = JSON(jsonData)
                        let e = Expense(details: expenseData)
                        callback(e)
                        
                        println("Successfully created expense \(e.name)")
                    }
                }
        }
    }
    
    
    //  /:uid/groups/:groupId/expenses/:expenseId
    class func getExpenseDetails(groupId: String, expenseId: String, callback:(Expense) -> Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/expenses/\(expenseId)"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting expense \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let expenseData = JSON(jsonData)
                        let expense = Expense(details: expenseData)
                        callback(expense)
                        println("Successfully fetched expense \(expense.name)")
                    }
                }
        }
    }
    
    //  /:uid/groups/:groupId/accounts
    class func getAccountsByGroup(groupId: String, callback:([Account]) -> Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/accounts"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting accounts \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let accountData = JSON(jsonData)
                        if let accountArray = accountData.array {
                            var accounts:[Account] = []

                            for acc in accountArray {
                                let account = Account(data: acc)
                                accounts.append(account)
                            }
                            callback(accounts)
                            println("Successfully fetched account details")
                        }
                    }
                }
        }
    }
    
    //  /:uid/accounts
    class func getAccounts(callback:([Account]) -> Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/accounts"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting accounts \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let accountData = JSON(jsonData)
                        if let accountArray = accountData.array {
                            var accounts:[Account] = []
                            
                            for acc in accountArray {
                                let account = Account(data: acc)
                                accounts.append(account)
                            }
                            callback(accounts)
                            println("Successfully fetched account details")
                        }
                    }
                }
        }
    }
    //  /:uid/accounts/:accountId
    class func getAccountDetails(accountId: String, callback:(acc: Account, exp: [Expense])-> Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/accounts/\(accountId)"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting account detail \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let accountData = JSON(jsonData)
                        let account = Account(data: accountData)
                        var expenses: [Expense] = []
                        if let expenseData = accountData["expenses"].array {
                            for exp in expenseData {
                                let expense = Expense(details: exp)
                                expenses.append(expense)
                            }
                        }
                        callback(acc: account, exp: expenses)
                        println("Successfully fetched account details")
                    }
                }
        }
    }
    
    class func updateAccount(account: Account, callback: (Account)->Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/accounts/\(account.aId)"
        
        let putBody = account.asDictionary()
        
        Alamofire.request(.PUT, url, parameters: putBody)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error updating account \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let accountData = JSON(jsonData)
                        let account = Account(data: accountData)
                        callback(account)
                        println("Successfully updated account details")
                    }
                }
        }
        
    }
    
    
    //  /:uid/messages
    class func getMessages(callback:([Message]) -> Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/messages"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting messages \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let messageData = JSON(jsonData)
                        if let messageArray = messageData.array {
                            var messages:[Message] = []
                            
                            for mess in messageArray {
                                let message = Message(data: mess)
                                messages.append(message)
                            }
                            callback(messages)
                            println("Successfully fetched messages")
                        }
                    }
                }
        }
    }
    
    class func sendMessage(msg: Message, callback: ()->Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/messages"
        var postBody = msg.asDictionary()
        Alamofire.request(.POST, url, parameters: postBody)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if let jsonData: AnyObject = jsonResponse {
                    let messageData = JSON(jsonData)
                    println("successfully sent message")
                    callback()
                }
        }
    }
    
    class func deleteMessage(messageId:String) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/messages/\(messageId)"
        Alamofire.request(.DELETE, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting messages \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let statusData = JSON(jsonData)
                        println("probably deleted message successfully")
                    }
                }
        }
    }
}