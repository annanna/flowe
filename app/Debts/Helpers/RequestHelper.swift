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
    
    //  /users
    class func getUserDetails(person: User, callback:(User) -> Void) {
        let customAllowedSet =  NSCharacterSet(charactersInString:"+() \"#%/<>?@\\^`{|}").invertedSet
        var escapedPhone = person.phoneNumber.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet) as String!
        var url = "\(dataUrl)/users?phone=\(escapedPhone)"
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
                        let user = UserHelper.JSONcreateUserIfDoesNotExist(userData)
                        callback(user)
                    }
                }
        }
    }
    class func createUser(user: User, callback:(User) -> Void) {
        let url = "\(dataUrl)/users"
        var postBody = JSONHelper.createDictionaryFromUser(user)
        Alamofire.request(.POST, url, parameters: postBody)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if let jsonData: AnyObject = jsonResponse {
                    let userData = JSON(jsonData)
                    let u = UserHelper.JSONcreateUserIfDoesNotExist(userData)
                    callback(u)
                }
        }
    }
    
    //  /:uid
    class func getUserById(uid: String, callback:(User) -> Void) {
        var url = "\(dataUrl)/\(uid)"
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
                        let user = UserHelper.JSONcreateUserIfDoesNotExist(userData)
                        callback(user)
                    }
                }
        }
    }
    
    //  /:uid/groups
    class func getGroups(callback:([Group]) -> Void) {
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
                            for group in groupArray {
                                var newGroup = Group(details: group)
                                groups.append(newGroup)
                            }
                            callback(groups)
                            println("Successfully fetched \(groups.count) groups")
                        }
                    }
                }
        }
    }
    class func postGroup(group: Group, callback:(Group) -> Void) {
        let url =  "\(dataUrl)/\(GlobalVar.currentUid)/groups"
        var users = JSONHelper.createDictionaryFromUsers(group.users)
        
        let postBody:[String: AnyObject] = [
            "name": group.name,
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
                        let g = Group(details: json)
                        callback(g)
                        
                        println("successfully created Group '\(g.name)'")
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
                        let group = Group(details: groupData)
                        callback(group)
                        
                        println("Successfully fetched group \(groupId)")
                    }
                }
        }
    }
    
    //  /:uid/groups/:groupId/expenses
    class func createExpense(groupId: String, expense: Expense, callback:(Expense) -> Void) {
        
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/expenses"
        
        var postBody: [String: AnyObject] = JSONHelper.createDictionaryFromExpense(expense)
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
    class func getAccounts(groupId: String, callback:([(user: User, action: String, amount: Double, partner: User)]) -> Void) {
        var url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/accounts"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting finances \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let financeData = JSON(jsonData)
                        if let financeArray = financeData.array {
                            var accounts:[(user: User, action: String, amount: Double, partner: User)] = []

                            for finance in financeArray {
                                let user = UserHelper.JSONcreateUserIfDoesNotExist(finance["user"])
                                let partner = UserHelper.JSONcreateUserIfDoesNotExist(finance["partner"])
                                
                                let account = (user: user, action: finance["action"].stringValue, amount: finance["amount"].doubleValue, partner: partner)
                                
                                accounts.append(account)
                            }
                            callback(accounts)
                            println("Successfully fetched finance details")
                        }
                    }
                }
        }
    }
}