//
//  UserDataTableViewController.swift
//  Debts
//
//  Created by Anna on 27.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class UserDataTableViewController: UITableViewController {
    @IBOutlet weak var offlineSwitch: UISwitch!
    @IBOutlet weak var uIDLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBAction func offlineSwitched(switchControl: UISwitch) {
        GlobalVar.offline = switchControl.on
    }
    @IBAction func logoutPressed(sender: UIButton) {
        GlobalVar.currentUid = ""
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let loginVC = storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        appDelegate.window?.rootViewController?.presentViewController(loginVC, animated: true, completion: nil)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.offlineSwitch.on = GlobalVar.offline
        self.uIDLabel.text = GlobalVar.currentUid
        self.nameLabel.text = GlobalVar.currentUser.getName()
    }
}
