//
//  PeopleView.swift
//  Debts
//
//  Created by Anna on 04.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class PeopleView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var people:[User] = [User]()
    let collectionCellIdentifier = "PeopleCell"
    @IBOutlet weak var peopleCollection: UICollectionView!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.people.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionCellIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        
        let btnSize:CGFloat = 40;
        var person = self.people[indexPath.row]
        var peopleBtn = PeopleButton(frame: CGRectMake(5, 5, btnSize, btnSize), user: person)
        cell.addSubview(peopleBtn)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
}
