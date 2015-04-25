//
//  AppDelegate.swift
//  Debts
//
//  Created by Anna on 14.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var groups = Groups()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        groups = Groups()
        println("new data")
        
        var winterurlaub = Group(name: "Winterurlaub", users: [User(rand: 1), User(rand: 2), User(rand: 3)], creator: User(rand: 2))
        var italiener = MoneyTransfer(name: "Italiener", creator: winterurlaub.creator, money: 57.12)
        italiener.addUsersInTransfers(winterurlaub.users)
        winterurlaub.addTransfer(italiener)
        
        
        var party = Group(name: "Geburtstagsparty", users: [User(rand:2), User(rand: 5), User(rand: 7)], creator: User(rand: 7))
        var einkauf = MoneyTransfer(name: "Einkauf", creator: party.users[0], money: 13.50)
        einkauf.addUsersInTransfers(party.users)
        party.addTransfer(einkauf)
        
        groups.addGroup(winterurlaub)
        groups.addGroup(party)

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

