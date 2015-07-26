//
//  ShareTableViewCell.swift
//  Debts
//
//  Created by Anna on 04.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class ShareTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var sliderMax: UILabel!
    
    var id:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.nameLabel.textColor = UIColor.darkGrayColor()
        self.amountText.textColor = UIColor.darkGrayColor()
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        // slider-steps in cents (+- 0.01)
        var sliderVal = sender.value.roundToMoney()
        sender.value = sliderVal
        self.amountText.text = Double(sliderVal).toMoneyString()
    }
    
    func updateCell(amount: Float) {
        self.amountSlider.value = amount
        self.sliderChanged(self.amountSlider)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
