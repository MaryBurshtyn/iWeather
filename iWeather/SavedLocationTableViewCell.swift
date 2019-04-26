import UIKit

class SavedLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var savedLocationLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    func setupCell(_ city: String, _ temperature: String, _ icon: String){
        savedLocationLabel.text = city
        savedLocationLabel.textColor = .white
        temperatureLabel.text = temperature
        temperatureLabel.textColor = .white
        guard let image = UIImage(named: icon + ".png" ) else {
            return
        }
        weatherIconImageView.image = image
    }

}
