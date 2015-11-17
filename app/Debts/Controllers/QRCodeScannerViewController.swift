//
//  QRCodeScannerViewController.swift
//  Debts
//
//  Created by Anna on 07.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//
//  Created by following guidelines from this tutorial:
//  http://www.appcoda.com/qr-code-reader-swift/
//

import UIKit
import AVFoundation
import SwiftyJSON

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var expense: Expense?
    var groupdId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up capturing
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) // we want to use the camera
        var error:NSError?
        let input: AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
//            input = try AVCaptureDeviceInput.deviceInputWithDevice(captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error != nil {
            print("\(error?.localizedDescription)")
            return
        }
        
        captureSession = AVCaptureSession() // capture session coordinates data flow between input device and output
        captureSession?.addInput(input as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode] // we are interested in data in form of QR Codes
        
        // show camera
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
        
        //view.bringSubviewToFront(messageLabel)
        
        // qr code reading
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                if let barCodeObj = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj) as? AVMetadataMachineReadableCodeObject {
                    qrCodeFrameView?.frame = barCodeObj.bounds

                    if metadataObj.stringValue != nil {
                        
                        let dataString = metadataObj.stringValue
                        let data = dataString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)

                        let json:JSON = JSON(data: data!)
                        let jsonGroupId = json["groupId"].stringValue
                        
                        if jsonGroupId == self.groupdId {
                            self.expense = Expense(details: json)
                            self.stopScanner()
                            self.performSegueWithIdentifier("saveExpense", sender: self)
                        } else {
                            messageLabel.text = "wrong group id received"
                        }
                    } else {
                        messageLabel.text = "no string value detected"
                        self.stopScanner()
                    }
                }
            } else {
                print("should not be called...right?")
            }
        }
    }
    
    func stopScanner() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
