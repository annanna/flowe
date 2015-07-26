//
//  AppDelegate.swift
//  Debts
//
//  Created by Anna on 14.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

struct GlobalVar {
    static var currentUser:User = User(rand: 1)
    static var currentUid:String = ""
}

struct colors {
    static let red: UIColor = UIColor(red: 250, green: 0, blue: 0, alpha: 0.5)
    static let green: UIColor = UIColor(red: 197, green: 224, blue: 212, alpha: 0)
    static let bgGreen: UIColor = UIColor(red: 87, green: 196, blue: 154, alpha: 0.5)
    
    static let paymentColors:[UIColor] = [
        UIColor(red: 0, green: 41.0, blue: 113.0, alpha: 0.3),
        UIColor(red: 16, green: 104, blue: 17, alpha: 0.3),
        UIColor(red: 144, green: 74, blue: 0, alpha: 0.3)
    ]
    // UIColor(red: 255, green: 114, blue: 80, alpha: 0.3),
    // UIColor(red: 236, green: 205, blue: 83, alpha: 0.3),
    // UIColor(red: 211, green: 219, blue: 135
}

extension Double {
    func roundToMoney() -> Double {
        return Double(round(self*100)/100)
    }
    func toMoneyString() -> String {
        // if number has decimals, display with 2 decimals, else crop zeros (e.g. 10 or 1.10)
        var isDecimal = Bool(self%1)
        if isDecimal {
            return String(format: "%.2f€", self)
        }
        return String(format: "%g€", self)
    }

}

extension String {
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }
    func toFloat() -> Float {
        return (self as NSString).floatValue
    }
}

extension Float {
    func roundToMoney() -> Float {
        return Float(round(self*100)/100)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.tabBarController = (storyboard.instantiateInitialViewController() as! UITabBarController)
        self.tabBarController?.selectedIndex = 1
        var initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        
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

