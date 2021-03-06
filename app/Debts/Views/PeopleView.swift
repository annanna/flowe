//
//  PeopleView.swift
//  Debts
//
//  Created by Anna on 04.06.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class PeopleView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var people = [User]()
    var activePeople = [User]()
    var peopleBtns = [PeopleButton]()
    let collectionCellIdentifier = "PeopleCell"
    var collectionView: UICollectionView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        self.addSubview(collectionView!)
    }
    
    func setPeopleInView(p: [User]) {
        self.people = p
        self.collectionView?.reloadData()
    }
    
    func setActivePeopleInView(activeP:[User]) {
        self.activePeople = activeP
        self.collectionView?.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionCellIdentifier, forIndexPath: indexPath) 
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        let person = self.people[indexPath.row]
        let peopleBtn = PeopleButton(user: person)
        if let _ = activePeople.indexOf(person) {
            peopleBtn.toggleSelection()
        }
        
        peopleBtns.append(peopleBtn)
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
