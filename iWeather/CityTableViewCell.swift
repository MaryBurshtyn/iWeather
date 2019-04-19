//
//  CityTableViewCell.swift
//  iWeather
//
//  Created by owner on 4/19/19.
//  Copyright © 2019 owner. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {


    @IBOutlet weak var cityLabel: UILabel!
    func setupCell(_ city: String){
        cityLabel.text = city
    }

}
