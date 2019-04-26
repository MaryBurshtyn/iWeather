import Foundation
import UIKit
import CoreGraphics
let backgroundImages = [
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
        guard let currWeather = data.currentWeatherData, let iconName = currWeather.icon,
        let direction = currWeather.windDirection,  let image = UIImage(named: "dir.png"),
        let temperature = currWeather.temperature, let feelsLike = currWeather.feellingTemperature,
        let velocity = currWeather.windSpeed  else {
            return
        }
        controller.temperatureLabel.text = temperature
        controller.feelsLikeTemperatureLabel.text = feelsLike
        controller.windVelocityLabel.text = velocity
        let radians = Float(direction ) * Float.pi / 180
        let newImage = image.rotate(radians: radians)
        controller.windDirectionImageView.image = newImage
        let imageName = iconName + ".png"
        controller.weatherImageView.image = UIImage(named: imageName)
        controller.cityLabel.text = data.city
        let bgName = backgroundImages[iconName] ?? "clear-day-bg.jpg"
        guard let bgImage = UIImage(named: bgName) else {
            return
        }
        controller.view.backgroundColor = UIColor(patternImage: bgImage)
        var plot : Array<[String: Int]> = []
        var index = 0
        for day in data.forecastData{
            guard let temp = day.temperatureMax else {
                return
            }
            let indexEndOfText = temp.index(temp.endIndex, offsetBy: -4)
            let temperature = String(temp[...indexEndOfText])
            plot.append([String(index): Int(temperature) ?? 0])
            index += 1
        }
        let xMargin = controller.view.frame.width/14
        let graph = GraphView(frame: CGRect(x: 0, y: 0, width:  controller.view.frame.width
            , height: 100), data: plot)
        graph.showLines = false
        graph.xMargin = xMargin
        graph.graphColor = .white
        controller.plotView.addSubview(graph)
        controller.forecastData = data.forecastData
        controller.updateForecast()
    }
}
