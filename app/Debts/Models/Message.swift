//
//  Message.swift
//  Debts
//
//  Created by Anna on 23.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftyJSON

class Message: NSObject {
    var mId = ""
    var sender = GlobalVar.currentUser
    var receiver = GlobalVar.currentUser
    var created = NSDate()
    var message = ""
    
    init(sender: User?, receiver: User?, message: String) {
        if let s = sender {
            self.sender = s
        }
        if let r = receiver {
            self.receiver = r
        }

        self.message = message
    }
    
    init(data: JSON) {
        self.mId = data["_id"].stringValue
        self.message = data["_id"].stringValue
        let senderId = data["sender"].stringValue
        let receiverId = data["receiver"].stringValue
        
        if let send = UserHelper.getUser(senderId) {
            self.sender = send
        } else {
            println("kenn ich nicht")
            self.sender = User(rand: 1)
        }
        
        if let r = UserHelper.getUser(receiverId) {
            self.sender = r
        } else {
            println("kenn ich nicht")
            self.sender = User(rand: 1)
        }
    }
    
    func asDictionary() -> [String: String] {
        return [
            "sender": self.sender.uID,
            "receiver": self.receiver.uID,
            "message": self.message
        ]
    }
   
}
