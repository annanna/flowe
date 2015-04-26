//
//  PeopleButton.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class PeopleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        self.addCustomBtn(frame, title: title)
    }
    
    func addCustomBtn(f: CGRect, title: String) {
        self.backgroundColor = UIColor(red: 192, green: 192, blue: 192, alpha: 0.3)
        self.layer.cornerRadius = f.width/2
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.frame = f
        self.setTitle(title, forState: UIControlState.Normal)
        self.titleLabel!.font = UIFont(name: self.titleLabel!.font.fontName, size: 15)
        
    }
}
