//
//  AccountDetailViewController.swift
//  Debts
//
//  Created by Anna on 26.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController, PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expenseTable: UITableView!
    @IBOutlet weak var accStatusLabel: UILabel!
    @IBOutlet weak var accTotalLabel: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!
    
    let cellIdentifier = "expenseCell"
    let showPaymentIdentifier = "payNow"
    
    var expenses = [Expense]()
    var aId = ""
    var account: Account?
    var currentPersonIsCreditor:Bool = true
    
    var environment: String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()
    
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
        if let acc = self.account {
            var otherName = ""
            if acc.creditor.isSame(GlobalVar.currentUser) {
                // der andere hat Schulden bei mir
                currentPersonIsCreditor = true
                otherName = acc.debtor.firstname
                paymentBtn.titleLabel?.text = "Request Payment"
            } else {
                // ich habe Schulden
                currentPersonIsCreditor = false
                otherName = acc.creditor.firstname
                paymentBtn.titleLabel?.text = "Pay now"
            }
            titleLabel.text = "\(otherName) & Ich"
            accStatusLabel.text = "\(acc.status)"
            accTotalLabel.text = acc.amount.toMoneyString()
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
            let message = Message(sender: GlobalVar.currentUser, receiver: self.account!.debtor, message: " wants money from you!")
            RequestHelper.sendMessage(message, callback: { () -> Void in
                var alert = UIAlertController(title: "Message", message: "Message sent to \(self.account!.debtor.firstname)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                    self.accStatusLabel.text = "1"
                })
            })
            
        } else {
            self.paying()
        }
    }

    
    func paying() {
        let payment = PayPalPayment(amount: 10.50, currencyCode: "EUR", shortDescription: "Schulden für Winterurlaub", intent: PayPalPaymentIntent.Sale)
        payment.items = [PayPalItem(name: "Meine Schulden", withQuantity: 1, withPrice: NSDecimalNumber(string: "10.5"), withCurrency: "EUR", withSku: "ABC")]
        payment.paymentDetails = PayPalPaymentDetails(subtotal: 10.5, withShipping: 0, withTax: 0)
        
        if payment.processable {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            presentViewController(paymentViewController, animated: true, completion: nil)
        } else {
            println("not processable")
        }
    }
    
    func setupPayPal() {
        PayPalMobile.initializeWithClientIdsForEnvironments(
            [
                "PayPalEnvironmentProduction": "AQ8OKPIzdyDlboX9iyxRCAzzkVtKKaGGADFouqbFv5oOXly7kznX3vA-hD4MwUSw9y-TRNMm2vm6wRN6",
                "PayPalEnvironmentSandbox": "AQ8OKPIzdyDlboX9iyxRCAzzkVtKKaGGADFouqbFv5oOXly7kznX3vA-hD4MwUSw9y-TRNMm2vm6wRN6"
            ]
        )
        
        // PayPal Config
        payPalConfig.acceptCreditCards = true
        payPalConfig.merchantName = "Debts App"
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0] as! String
        payPalConfig.payPalShippingAddressOption = .PayPal
        
        PayPalMobile.preconnectWithEnvironment(environment)
    }

    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        println("PayPal Payment Cancelled")
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        println("PayPal Payment Success !")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            println("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
        })
    }

    // Future Payment
    func payPalFuturePaymentDidCancel(futurePaymentViewController: PayPalFuturePaymentViewController!) {
        println("PayPal Future Payment Authorization Canceled")
        futurePaymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func payPalFuturePaymentViewController(futurePaymentViewController: PayPalFuturePaymentViewController!, didAuthorizeFuturePayment futurePaymentAuthorization: [NSObject : AnyObject]!) {
        println("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        futurePaymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("done")
        })
    }
    
    
    // PayPalProfileSharingDelegate
    func userDidCancelPayPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController!) {
        println("profile sharing cancelled")
        profileSharingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    func payPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController!, userDidLogInWithAuthorization profileSharingAuthorization: [NSObject : AnyObject]!) {
        println("profile sharing authorization successfull")
        
        profileSharingViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("hallo")
        })
    }
    
}
