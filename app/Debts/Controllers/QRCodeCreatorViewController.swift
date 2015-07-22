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
    var transfer: MoneyTransfer!
    var groupId = ""
    
    override func viewDidLoad() {
        println("\(transfer.name)")
        super.viewDidLoad()
        self.generateDataFromTransfer()
    }
    
    func generateDataFromTransfer() {

        var transferDictionary : [String: AnyObject] =
            JSONHelper.createDictionaryFromTransfer(self.transfer)
        transferDictionary["groupId"] = self.groupId
        var dataString = JSONHelper.JSONStringify(transferDictionary)
        
        let transferData = dataString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        self.generateImg(transferData!)
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
