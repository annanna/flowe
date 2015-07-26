//
//  AccountDetailViewController.swift
//  Debts
//
//  Created by Anna on 26.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountDetailViewController: UIViewController, PayPalPaymentDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expenseTable: UITableView!
    @IBOutlet weak var accStatusLabel: UILabel!
    @IBOutlet weak var accTotalLabel: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!
    
    let cellIdentifier = "expenseCell"
    let showPaymentIdentifier = "payNow"
    
    var expenses = [Expense]()
    var aId = ""
    var account: Account!
    var currentPersonIsCreditor:Bool = true
    var groupName = ""
    
    let paymentStatus = ["Unbezahlt", "Bestätigung ausstehend", "Bezahlt"]
    var payPalConfig = PayPalConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPayPal()
        RequestHelper.getAccountDetails(self.aId, callback: { (acc, exp) -> Void in
            self.expenses = exp
            self.account = acc
            self.setTopBar()
            self.expenseTable.reloadData()
        })
    }
    
    func setTopBar() {
        var otherName = ""
        if account.currentUserIsDebtor() {
            // ich habe Schulden
            currentPersonIsCreditor = false
            otherName = account.creditor.firstname
            paymentBtn.setTitle("Pay Now", forState: UIControlState.Normal)
        } else {
            // der andere hat Schulden bei mir
            currentPersonIsCreditor = true
            otherName = account.debtor.firstname
            paymentBtn.setTitle("Request Payment", forState: UIControlState.Normal)
        }
        titleLabel.text = "\(otherName) & Ich"
        accTotalLabel.text = account.amount.toMoneyString()
        displayStatus()
    }
    
    func displayStatus() {
        let status = self.account.status
        accStatusLabel.text = self.paymentStatus[status]
        let color = colors.paymentColors[status]
        self.accStatusLabel.backgroundColor = color
        if status > 0 {
            self.paymentBtn.hidden = true
        }
    }
    
    // MARK: - Table view data source & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let expense = self.expenses[indexPath.row]
        cell.textLabel?.text = expense.generateConclusion()
        return cell
    }    
    
    @IBAction func paymentPressed(sender: UIButton) {
        if currentPersonIsCreditor {
            // send message and show alert
            let message = Message(sender: GlobalVar.currentUser, receiver: self.account.debtor, message: " wants money from you!")
            RequestHelper.sendMessage(message, callback: { () -> Void in
                var alert = UIAlertController(title: "Message", message: "Message sent to \(self.account.debtor.firstname)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
        } else {
            let alertController = UIAlertController(title: nil, message: "Wähle hier die Zahlungsart aus", preferredStyle: .ActionSheet)
            let cashPayment = UIAlertAction(title: "Barzahlung", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.paymentDone()
                
            })
            let payPalPayment = UIAlertAction(title: "PayPal", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                
                let payment = PayPalPayment()
                payment.amount = NSDecimalNumber(double: self.account.amount)
                payment.currencyCode = "EUR"
                payment.shortDescription = "Schulden für \(self.groupName)"
                payment.intent = PayPalPaymentIntent.Sale
                
                if payment.processable {
                    let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.payPalConfig, delegate: self)
                    self.presentViewController(paymentViewController, animated: true, completion: nil)
                } else {
                    println("payment not processable")
                }
            })
            alertController.addAction(cashPayment)
            alertController.addAction(payPalPayment)
            
            self.presentViewController(alertController, animated: true, completion: nil)

            

        }
    }
    
    func paymentDone() {
        self.account?.status++
        self.displayStatus()
        RequestHelper.updateAccount(self.account, callback: { (acc) -> Void in
            self.account = acc
            self.setTopBar()
            let msg = Message(sender: GlobalVar.currentUser, receiver: self.account.creditor, message: "hat \(self.account.amount.toMoneyString()) bezahlt")
            RequestHelper.sendMessage(msg, callback: { () -> Void in
                println("message sent to \(self.account.creditor.firstname)")
            })
        })
    }
    
    func setupPayPal() {
        PayPalMobile.initializeWithClientIdsForEnvironments(
            [
                PayPalEnvironmentSandbox: "AQ8OKPIzdyDlboX9iyxRCAzzkVtKKaGGADFouqbFv5oOXly7kznX3vA-hD4MwUSw9y-TRNMm2vm6wRN6"
            ]
        )
        
        // PayPal Config
        payPalConfig.acceptCreditCards = true
        payPalConfig.defaultUserPhoneNumber = GlobalVar.currentUser.phoneNumber
        payPalConfig.defaultUserEmail = "myDebts@abc.com" // GlobalVar.currentUser.phoneNumber
        payPalConfig.rememberUser = true
        payPalConfig.alwaysDisplayCurrencyCodes = true
        //payPalConfig.merchantName = "Debts App"
        payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOption.None
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentNoNetwork)
    }

    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        println("PayPal Payment Cancelled")
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        println("PayPal Payment Success !")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.verifyCompletedPayment(completedPayment)
            self.paymentDone()
        })
    }

    func verifyCompletedPayment(completedPayment: PayPalPayment) {
        var conf = completedPayment.confirmation
        var confirmation = JSON(conf)
        var paymentId = confirmation["response"]["id"].stringValue
        println("payment id: \(paymentId)")
        
        // (1) get access token
        
        /* 
            curl -v https://api.sandbox.paypal.com/v1/oauth2/token \
            -H "Accept: application/json" \
            -H "Accept-Language: en_US" \
            -u "<ClientId>:<SecretKey>" \
            -d "grant_type=client_credentials"

        */
        
        // (2) get payment from server
        
        /*
            curl -v -X GET https://api.sandbox.paypal.com/v1/payments/payment \
            -H "Content-Type:application/json" \
            -H "Authorization: Bearer <AccessToken>"
        */
    }
}
