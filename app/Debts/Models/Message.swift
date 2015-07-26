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
        super.init()
        self.mId = data["_id"].stringValue
        self.message = data["message"].stringValue
        let senderId = data["sender"].stringValue
        let receiverId = data["receiver"].stringValue
        self.setSenderUser(senderId)
        self.setReceiverUser(receiverId)
    }
    
    func setSenderUser(senderId: String) {
        UserHelper.getUserById(senderId, callback: { (user) -> Void in
            self.sender = user
        })
    }
    func setReceiverUser(receiverId: String) {
        UserHelper.getUserById(receiverId, callback: { (user) -> Void in
            self.receiver = user
        })
    }
    
    func asDictionary() -> [String: String] {
        return [
            "sender": self.sender.uID,
            "receiver": self.receiver.uID,
            "message": self.message
        ]
    }
   
}
