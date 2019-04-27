import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    func setUpCell(_ data: ForecastData){
        guard let iconName = data.icon,
        let temperature = data.temperatureMax,
        let date = data.date else {
            return
        }
        weatherImageView.image = UIImage(named: iconName + ".png")
        temperatureLabel.text = temperature
        dateLabel.text = date
    }
}
