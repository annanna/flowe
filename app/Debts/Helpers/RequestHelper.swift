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
        
        if let coreDataUser = User.findUserIfExists(predicate!, context: self.context!) {
            // user found in local Core Data db
            callback(coreDataUser)
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
                        self.saveUserInCoreData(userData, callback: callback)
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
    
    private class func createUser(user: [String: String], callback:(User) -> Void) {
        let url = "\(dataUrl)/users"
        Alamofire.request(.POST, url, parameters: user)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if let jsonData: AnyObject = jsonResponse {
                    let userData = JSON(jsonData)
                    self.saveUserInCoreData(userData, callback: callback)
                }
        }
    }
    
    private class func saveUserInCoreData(userData: JSON, callback:(User)->Void) {
        // store user in local db
        User.findOrCreateUser(userData, inContext: self.context!) { (user) -> Void in
            self.appDelegate.saveContext()
            callback(user)
        }
    }
    

    //  /:uid/groups
    class func getGroups(callback:([Group]) -> Void) {
        
        if GlobalVar.offline {
            Group.findGroupsWithUser(self.context!, callback: callback)
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
                            var groups = [Group]()
                            var groupCount = groupArray.count
                            
                            for group in groupArray {
                                Group.findOrCreateGroup(group, inContext: self.context!, callback: { (newGroup:Group) -> Void in
                                    groups.append(newGroup)
                                    self.appDelegate.saveContext()
                                    groupCount -= 1
                                    
                                    if groupCount == 0 {
                                        println("Successfully fetched \(groups.count) groups")
                                        callback(groups)
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
                        self.saveGroupInCoreData(groupData, callback: callback)
                        println("Successfully fetched group \(groupId)")
                    }
                }
        }
    }
    
    private class func saveGroupInCoreData(groupData: JSON, callback:(Group)->Void) {
        // store group in local db
        Group.findOrCreateGroup(groupData, inContext: self.context!) { (group) -> Void in
            self.appDelegate.saveContext()
            callback(group)
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