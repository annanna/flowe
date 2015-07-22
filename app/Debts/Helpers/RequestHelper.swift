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
    
    class func postGroup(group: Group, callback:(Group) -> Void) {
        var users = JSONHelper.createDictionaryFromUsers(group.users)
        
        let postBody:[String: AnyObject] = [
            "name": group.name,
            "users": users,
            "creator": GlobalVar.currentUid
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(dataUrl)/\(GlobalVar.currentUid)/groups")!)
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
    
    class func getGroups(callback:([Group]) -> Void) {
        println("currentUid: \(GlobalVar.currentUid)")
        Alamofire.request(.GET, "\(dataUrl)/\(GlobalVar.currentUid)/groups/")
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
    
    class func postTransfer(groupId: String, transfer: MoneyTransfer, callback:(MoneyTransfer) -> Void) {        
        var postBody: [String: AnyObject] = JSONHelper.createDictionaryFromTransfer(transfer)
        
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/transfers"
        
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
                    println("Error creating transfer \(transfer.name)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let transferData = JSON(jsonData)
                        let t = MoneyTransfer(details: transferData)
                        callback(t)
                        
                        println("Successfully created transfer \(t.name)")
                    }
                }
        }
    }
    
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
    
    class func getTransferDetails(transferId: String, callback:(MoneyTransfer) -> Void) {
        var url = "\(dataUrl)/transfers?transferId=\(transferId)"
        Alamofire.request(.GET, url)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error getting transfer \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let transferData = JSON(jsonData)
                        let transfer = MoneyTransfer(details: transferData)
                        callback(transfer)
                        println("Successfully fetched transfer \(transfer.name)")
                    }
                }
        }
    }
    
    class func createUser(user: User, callback:(User) -> Void) {
        var postBody = JSONHelper.createDictionaryFromUser(user)
        Alamofire.request(.POST, "\(dataUrl)/users", parameters: postBody)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if let jsonData: AnyObject = jsonResponse {
                    let userData = JSON(jsonData)
                    let u = UserHelper.JSONcreateUserIfDoesNotExist(userData)
                    callback(u)
                }
        }
    }
    
    class func getFinance(groupId: String, callback:([(user: User, action: String, amount: Double, partner: User)]) -> Void) {
        var url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/finances"
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