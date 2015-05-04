//
//  BalanceTableViewCell.swift
//  Debts
//
//  Created by Anna on 04.05.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

import UIKit

class BalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountSlider: UISlider!
    
    @IBOutlet weak var sliderMax: UILabel!
    
    var id:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func sliderChanged(sender: UISlider) {
        // slider-steps in cents (+- 0.01)
        var sliderVal = round(100*sender.value) / 100
        sender.value = sliderVal
        self.amountLabel.text = "\(sender.value)€"
    }
    
    func updateCell(amount: Float) {
        self.amountSlider.value = amount
        self.sliderChanged(self.amountSlider)
    }
}
