//
//  SettingsTableViewController.swift
//  Debts
//
//  Created by Anna on 27.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var offlineSwitch: UISwitch!

    @IBAction func offlineSwitched(switchControl: UISwitch) {
        GlobalVar.offline = switchControl.on
    }
    
    override func viewDidLoad() {
        self.offlineSwitch.on = GlobalVar.offline
    }
}
