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
    
    class func createDictionaryFromUser(user: User) -> [String: String] {
        return [
            "phone": user.phoneNumber,
            "firstname": user.firstname,
            "lastname": user.lastname
        ]
    }
    
    class func createDictionaryFromUsers(users:[User]) -> [[String: String]] {
        var userDict=[[String: String]]()
        for user in users {
            userDict += [createDictionaryFromUser(user)]
        }
        return userDict
    }
    
    class func createDictionaryFromExpense(expense:Expense) -> [String: AnyObject] {
        var whoPayed = [[String: AnyObject]]()
        for (user, amount) in expense.payed {
            var payed:[String: AnyObject] = [
                "user": user.uID,
                "amount": amount
            ]
            whoPayed.append(payed)
        }
        var whoTookPart = [[String: AnyObject]]()
        for (user, amount) in expense.participated {
            var participated:[String: AnyObject] = [
                "user": user.uID,
                "amount": amount
            ]
            whoTookPart.append(participated)
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy HH:mm"
        let expenseDate = dateFormatter.stringFromDate(expense.timestamp)
        
        var postBody: [String: AnyObject] = [
            "name": expense.name,
            "creator": GlobalVar.currentUid,
            "timestamp": expenseDate,
            "total": expense.moneyPayed,
            "notes": expense.notes,
            "whoTookPart": whoTookPart,
            "whoPayed": whoPayed
        ]
        return postBody
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