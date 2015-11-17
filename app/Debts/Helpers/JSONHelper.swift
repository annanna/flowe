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
    
    class func JSONObjToStringDic(json: JSON) -> [String: String] {
        var dic = [String: String]()
        for (key, object) in json {
            dic[key] = object.stringValue
        }
        return dic
    }
    
    class func JSONToDictionary(dataArray:[JSON]) -> [[String: AnyObject]] {
        var dataDic:[[String:AnyObject]] = []
        for data in dataArray {
            let dic:[String: AnyObject] = data.dictionaryObject!
            dataDic.append(dic)
        }
        return dataDic
    }
    
    class func printDic(dic: [String: AnyObject]) {
        for (key, value) in dic {
            if let arr = value as? [String: Double] {
                print("\(key):")
                for (arrKey, arrValue) in arr {
                    print("\(arrKey): \(arrValue)")
                }
            } else {
                print("\(key): \(value)")
            }
        }
    }
    
    class func JSONStringify(jsonObj: AnyObject) -> String {
        var e: NSError?
        let jsonData: NSData?
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(
                        jsonObj,
                        options: NSJSONWritingOptions(rawValue: 0))
        } catch let error as NSError {
            e = error
            jsonData = nil
        }
        if e != nil {
            return ""
        } else {
            let dataString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
            return (dataString! as String)
        }
    }
    
}