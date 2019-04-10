import Foundation
import SwiftyJSON

struct CurrentWeatherData {
    
    var temperature: String?
    var description: String?
    var icon: String?
    var windSpeed: String?
    var windDirection: Int?
    var feellingTemperature: String?
    
    
    init(data: Any) {
        let json = JSON(data)
        let currentWeather = json["currently"]
        
        if let temperature = currentWeather["temperature"].float {
            self.temperature = String(format: "%.0f", toCelsius(temperature)) + " ºC"
        } else {
            self.temperature = "--"
        }
        if let windSpeed = currentWeather["windSpeed"].float {
            self.windSpeed = String(format: "%.0f", windSpeed) + " m/s"
        } else {
            self.windSpeed = "--"
        }
        if let windDirection = currentWeather["windBearing"].int {
            self.windDirection = windDirection
        } else {
            self.windDirection = 0
        }
        if let feellingTemperature = currentWeather["apparentTemperature"].float {
            
            self.feellingTemperature = String(format: "%.0f", toCelsius(feellingTemperature)) + " ºC"
        } else {
            self.feellingTemperature = "--"
        }
        self.description = currentWeather["summary"].string ?? "--"
        self.icon = currentWeather["icon"].string ?? "--"
    }
    
    func toCelsius(_ temperature: Float) -> Float{
      return  5 * (temperature - 32)/9
    }
}
