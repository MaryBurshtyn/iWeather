//
//  SavedLocationTableViewCell.swift
//  iWeather
//
//  Created by owner on 4/20/19.
//  Copyright © 2019 owner. All rights reserved.
//

import UIKit

class SavedLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var savedLocationLabel: UILabel!
    func setupCell(_ city: String, _ temperature: String){
        savedLocationLabel.text = city
        temperatureLabel.text = temperature
    }

}
