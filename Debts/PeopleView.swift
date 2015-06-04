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
    var collectionView: UICollectionView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        println("width: \(self.frame.width) height: \(self.frame.height)")
        self.createCollectionView()
    }
    
    func createCollectionView() {
        var collectionFrame = self.frame
        collectionFrame.origin = CGPoint(x: 0, y: 0)
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        collectionView?.backgroundColor = UIColor.clearColor()
        println("width: \(collectionFrame.width) height: \(collectionFrame.height)")
        self.addSubview(collectionView!)
    }
    
    func setPeopleInView(p: [User]) {
        self.people = p
        self.collectionView?.reloadData()
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionCellIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        
        var person = self.people[indexPath.row]
        var peopleBtn = PeopleButton(user: person)
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
