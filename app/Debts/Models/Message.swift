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
    var sender: User
    var receiver = GlobalVar.currentUser
    var created = NSDate()
    var message = ""
    
    init(sender: User) {
        self.sender = sender
    }
    
    init(data: JSON) {
        self.mId = data["_id"].stringValue
        self.message = data["_id"].stringValue
        let senderId = data["_id"].stringValue
        
        if let send = UserHelper.getUser(senderId) {
            self.sender = send
        } else {
            println("kenn ich nicht")
            self.sender = User(rand: 1)
        }
    }
   
}
