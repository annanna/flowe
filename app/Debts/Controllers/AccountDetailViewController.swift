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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let expense = self.expenses[indexPath.row]
        cell.textLabel?.text = expense.generateConclusion()
        return cell
    }
    
    @IBAction func paymentPressed(sender: UIButton) {
        if currentPersonIsCreditor {
            // send message and show alert
            let message = Message(sender: GlobalVar.currentUser, receiver: self.account.debtor, message: " wants money from you!")
            RequestHelper.sendMessage(message, callback: { () -> Void in
                let alert = UIAlertController(title: "Message", message: "Message sent to \(self.account.debtor.firstname)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
        } else {
            // let user pay by cash or PayPal
            let alertController = UIAlertController(title: nil, message: "Wähle hier die Zahlungsart aus", preferredStyle: .ActionSheet)
            let cashPayment = UIAlertAction(title: "Barzahlung", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.paymentDone()
                
            })
            let payPalPayment = UIAlertAction(title: "PayPal", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.payWithPayPal()
                
            })
            alertController.addAction(cashPayment)
            alertController.addAction(payPalPayment)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func paymentDone() {
        self.account?.status += 1
        self.displayStatus()
        RequestHelper.updateAccount(self.account, callback: { (acc) -> Void in
            self.account = acc
            self.setTopBar()
            let msg = Message(sender: GlobalVar.currentUser, receiver: self.account.creditor, message: "hat \(self.account.amount.toMoneyString()) bezahlt")
            RequestHelper.sendMessage(msg, callback: { () -> Void in
                print("message sent to \(self.account.creditor.firstname)")
            })
        })
    }
    
    func payWithPayPal() {
        
        let config = self.setupPayPal()
        
        // set up payment
        let payment = PayPalPayment()
        payment.amount = NSDecimalNumber(double: self.account.amount.roundToMoney())
        payment.currencyCode = "EUR"
        payment.shortDescription = "Schulden für \(self.groupName)"
        payment.intent = PayPalPaymentIntent.Sale
        
        if payment.processable {
            if let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: config, delegate: self) {
                self.presentViewController(paymentViewController, animated: true, completion: nil)
            }
        } else {
            print("payment is not processable")
        }
        
    }
    
    
    func verifyCompletedPayment(completedPayment: PayPalPayment) {
        let conf = completedPayment.confirmation
        var confirmation = JSON(conf)
        let paymentId = confirmation["response"]["id"].stringValue
        print("payment id: \(paymentId)")
        
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
    
    func setupPayPal() -> PayPalConfiguration {
        PayPalMobile.initializeWithClientIdsForEnvironments(
            [
                PayPalEnvironmentSandbox: "AQ8OKPIzdyDlboX9iyxRCAzzkVtKKaGGADFouqbFv5oOXly7kznX3vA-hD4MwUSw9y-TRNMm2vm6wRN6"
            ]
        )
        
        // Set up config
        let payPalConfig = PayPalConfiguration()
        payPalConfig.acceptCreditCards = true
        payPalConfig.defaultUserPhoneNumber = GlobalVar.currentUser.phoneNumber
        payPalConfig.defaultUserEmail = "myDebts@abc.com" // GlobalVar.currentUser.phoneNumber
        payPalConfig.rememberUser = true
        payPalConfig.alwaysDisplayCurrencyCodes = true
        //payPalConfig.merchantName = "Debts App"
        payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOption.None
        
        // Preconnect
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentNoNetwork)
        
        return payPalConfig
    }
    
    
    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        print("payment Cancelled")
        
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        print("payment success")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.verifyCompletedPayment(completedPayment)
            self.paymentDone()
        })
    }
}
