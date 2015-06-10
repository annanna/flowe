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
    
    static let dataUrl = "http://192.168.1.8:3000"
    
    class func postGroup(group: Group, callback:(Group) -> Void) {
        var postBody:[String: AnyObject] = [
            "name": group.name,
            "users": group.users,
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
    
    class func postTransfer(groupId: String, data: [String: AnyObject], callback:(JSON) -> Void) {
        let url = "\(dataUrl)/\(GlobalVar.currentUid)/groups/\(groupId)/transfers"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var transferName = data["name"] as! String
        
        Alamofire.request(request)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if (error != nil) {
                    println("Error creating transfer \(transferName)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let transferData = JSON(jsonData)
                        callback(transferData)
                        
                        println("Successfully created transfer \(transferName)")
                    }
                }
        }
    }
    
    class func getGroupDetails(groupId: String, callback:(JSON)->Void) {
        Alamofire.request(.GET, "\(dataUrl)/groups?groupId=\(groupId)")
            .responseJSON {
                (request, response, jsonResponse, error) in
                if(error != nil) {
                    println("Error fetching group \(groupId) \(error)")
                    println(request)
                    println(response)
                } else {
                    if let jsonData: AnyObject = jsonResponse {
                        let groupData = JSON(jsonData)
                        callback(groupData)
                        
                        println("Successfully fetched group \(groupId)")
                    }
                }
        }
    }
    
    class func getUserDetails(person: User, callback:(JSON) -> Void) {
        var escapedPhone = person.phoneNumber.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) as String!
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
                        callback(userData)
                    }
                }
        }
    }
    
    class func getTransferDetails(transferId: String, callback:(JSON) -> Void) {
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
                        callback(transferData)
                        println("Successfully fetched transfer \(transferId)")
                    }
                }
        }
    }
    
    class func createUser(data: [String: String], callback:(JSON) -> Void) {
        Alamofire.request(.POST, "\(dataUrl)/users", parameters: data)
            .responseJSON {
                (request, response, jsonResponse, error) in
                if let jsonData: AnyObject = jsonResponse {
                    let userData = JSON(jsonData)
                    callback(userData)
                }
        }
    }
}