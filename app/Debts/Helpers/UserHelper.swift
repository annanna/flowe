//
//  UserHelper.swift
//  Debts
//
//  Created by Anna on 09.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftyJSON

public class UserHelper: NSObject {
    
    static var userDic = [String: User]()
    
    class func createUserIfDoesNotExist(user: User) {
        if let u = userDic[user.uID] {
            
        } else {
            userDic[user.uID] = user
        }
    }
    
    class func getUser(id: String) -> User? {
        if let user = userDic[id] {
            return user
        }
        return nil
    }
    
    class func createUser(json:JSON) {
        let user = User(details: json)
        userDic[user.uID] = user
    }
    class func JSONcreateUserIfDoesNotExist(json: JSON) -> User {
        var uid = json["_id"].stringValue
        if let u = userDic[uid] {
            u.updateUser(json)
            return u
        }
        let user = User(details: json)
        userDic[user.uID] = user
        return user
    }
    
    class func addUser(user: User) {
        userDic[user.uID] = user
    }
    
}