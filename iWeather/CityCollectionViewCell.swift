import Foundation
import UIKit
let backgroungImages = [
    "clear-day": "clear-day-bg.jpg",
    "clear-night": "clear-night-bg.jpg",
    "cloudy" : "cloudy-day1-bg.jpg",
    "fog": "fog1-bg.png",
    "partly-cloudy-day": "cloudy-day1-bg.jpg",
    "partly-cloudy-night": "cloudy-night-bg.jpg",
    "rain": "rain1-bg.jpg",
    "sleet": "cloudy-day-bg.jpg",
    "snow" : "cloudy-day1-bg.jpg",
    "wind": "cloudy-day1-bg.jpg",
]
class CityCollectionViewCell: UICollectionViewCell {
    
    func setUpCell(_ data: RequiredData, _ controller: ChildViewController)  {
        controller.temperatureLabel.text = data.currentWeatherData?.temperature
        guard let currWeather = data.currentWeatherData, let iconName = currWeather.icon else {
            return
        }
        let imageName = iconName + ".png"
        controller.weatherImageView.image = UIImage(named: imageName)
        controller.cityLabel.text = data.city
        let bgName = backgroungImages[iconName] ?? "clear-day-bg.jpg"
        guard let bgImage = UIImage(named: bgName) else {
            return
        }
        controller.view.backgroundColor = UIColor(patternImage: bgImage)
    }
}
