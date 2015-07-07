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
    //var sendingData: NSData!
    var transfer: MoneyTransfer!
    
    override func viewDidLoad() {
        println("\(transfer.name)")
        super.viewDidLoad()
        //self.generateImg()
        self.generateDataFromTransfer()
    }
    
    func generateDataFromTransfer() {
        let transferDictionary : [String: AnyObject] =
            [
                "tID": transfer.tID,
                "name": transfer.name,
                //"timestamp": transfer.timestamp,
                "notes": transfer.notes,
                "creator": transfer.creator.uID,
                "moneyPayed": transfer.moneyPayed
            ]
        /*
        let transferData: NSData = NSKeyedArchiver.archivedDataWithRootObject(transferDictionary)
        let transferDic: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(transferData)
        
        let dataString = NSString(data: transferData, encoding: NSUTF8StringEncoding)
        println(dataString)
        */
        var dataString = JSONStringify(transferDictionary)
        
        
        let transferData = dataString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        self.generateImg(transferData!)
        
    }
    
    func JSONStringify(jsonObj: AnyObject) -> String {
        var e: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(
            jsonObj,
            options: NSJSONWritingOptions(0),
            error: &e)
        if e != nil {
            return ""
        } else {
            var dataString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
            return (dataString! as! String)
        }
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
