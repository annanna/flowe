//
//  QRCodeCreatorViewController.swift
//  Debts
//
//  Created by Anna on 07.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//
//  Created by following guidelines from this tutorial:
//  http://www.appcoda.com/qr-code-generator-tutorial/
//

import UIKit

class QRCodeCreatorViewController: UIViewController {

    @IBOutlet weak var imgQRCode: UIImageView!
    
    var qrcodeImg: CIImage!
    var expense: Expense!
    var groupId = ""
    
    override func viewDidLoad() {
        println("\(expense.name)")
        super.viewDidLoad()
        self.generateDataFromExpense()
    }
    
    func generateDataFromExpense() {

        var expenseDictionary : [String: AnyObject] = self.expense.asDictionary()
        expenseDictionary["groupId"] = self.groupId
        var dataString = JSONHelper.JSONStringify(expenseDictionary)
        
        let expenseData = dataString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        self.generateImg(expenseData!)
    }
    
    func generateImg(dataToSend: NSData) {
        if qrcodeImg == nil {
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter.setValue(dataToSend, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImg = filter.outputImage
            
            displayQRCodeImage()
        }
    }
    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImg.extent().size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImg.extent().size.height
        // extend returns the frame of the image

        let transformedImg = qrcodeImg.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        imgQRCode.image = UIImage(CIImage: transformedImg)
    }

    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
