//
//  PeopleButton.swift
//  Debts
//
//  Created by Anna on 26.04.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class PeopleButton: UIButton {
    
    let bgColorNormal: UIColor = UIColor(red: 192, green: 192, blue: 192, alpha: 0.3)
    let bgColorClicked: UIColor = UIColor(red: 192, green: 192, blue: 192, alpha: 0.6)
    
    var uid: User = User(phone: "")
    var isClicked: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, user: User) {
        self.init(frame: frame)
        self.addCustomBtn(frame, user: user)
    }
    
    convenience init(user: User) {
        let btnMargin:CGFloat = 0.0
        let btnSize:CGFloat = 40.0

        var frame = CGRectMake(btnMargin, btnMargin, btnSize, btnSize)
        self.init(frame: frame)
        self.addCustomBtn(frame, user: user)
    }
    
    func addCustomBtn(f: CGRect, user: User) {
        self.backgroundColor = bgColorNormal
        self.layer.cornerRadius = f.width/2
        self.clipsToBounds = true;
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.frame = f
        if let img = user.img {
            self.setImage(img, forState: UIControlState.Normal)
        } else {
            self.setTitle(user.getName(), forState: UIControlState.Normal)
            self.titleLabel!.font = UIFont(name: self.titleLabel!.font.fontName, size: 15)
        }
        self.uid = user
    }
    
    func toggleSelection() {
        if !self.isClicked {
            self.backgroundColor = bgColorClicked
            self.layer.borderColor = (UIColor.darkGrayColor()).CGColor
            self.layer.borderWidth = 0.5
        } else {
            self.backgroundColor = bgColorNormal
            self.layer.borderWidth = 0
        }
        self.isClicked = !self.isClicked
    }
}
