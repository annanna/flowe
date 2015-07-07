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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateImg()
    }
    
    func generateImg() {
        if qrcodeImg == nil {
            let sampleString = "anna"
            let data = (sampleString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter.setValue(data, forKey: "inputMessage")
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

}
