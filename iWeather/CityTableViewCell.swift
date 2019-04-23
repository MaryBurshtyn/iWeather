import UIKit

class CityTableViewCell: UITableViewCell {


    @IBOutlet weak var cityLabel: UILabel!
    func setupCell(_ city: String){
        cityLabel.text = city
        cityLabel.textColor = .white
    }

}
