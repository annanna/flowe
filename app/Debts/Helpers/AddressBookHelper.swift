//
//  AddressBookHelper.swift
//  Debts
//
//  Created by Anna on 23.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import Foundation
import SwiftAddressBook
import AddressBook

public class AddressBookHelper {
    
    class func loadPeopleFromAddressBook(callback: [SwiftAddressBookPerson]->Void) {
        //let status: ABAuthorizationStatus = SwiftAddressBook.authorizationStatus()
        let addressBook: SwiftAddressBook? = swiftAddressBook
        swiftAddressBook?.requestAccessWithCompletion({(success, error) -> Void in
            if success {
                if let book = addressBook {
                    if let people = book.allPeople {
                        callback(people)
                    }
                }
            } else {
                print("User denied access to addressbook")
            }
        })
    }
    
}