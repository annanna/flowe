//
//  JSONHelper.swift
//  Debts
//
//  Created by Anna on 05.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import Foundation
import SwiftyJSON

public class JSONHelper {
    
    class func createDictionaryFromUsers(users:[User]) -> [[String: String]] {
        var userDict=[[String: String]]()
        for user in users {
            userDict += [user.asDictionary()]
        }
        return userDict
    }
    
    class func JSONToDictionary(dataArray:[JSON]) -> [[String: AnyObject]] {
        var dataDic:[[String:AnyObject]] = []
        for data in dataArray {
            var dic:[String: AnyObject] = data.dictionaryObject!
            dataDic.append(dic)
        }
        return dataDic
    }
    
    class func printDic(dic: [String: AnyObject]) {
        for (key, value) in dic {
            if let arr = value as? [String: Double] {
                println("\(key):")
                for (arrKey, arrValue) in arr {
                    println("\(arrKey): \(arrValue)")
                }
            } else {
                println("\(key): \(value)")
            }
        }
    }
    
    class func JSONStringify(jsonObj: AnyObject) -> String {
        var e: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(
            jsonObj,
            options: NSJSONWritingOptions(0),
            error: &e)
        if e != nil {
            return ""
        } else {
            var dataString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
            return (dataString! as! String)
        }
    }
    
}