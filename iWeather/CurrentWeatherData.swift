import Foundation
import SwiftyJSON

class CurrentWeatherData : NSObject, NSCoding {
    
    var temperature: String?
    var weatherDescription: String?
    var icon: String?
    var windSpeed: String?
    var windDirection: Int?
    var feellingTemperature: String?
    var date: String?

    init(data: Any) {
        super.init()
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
        
        if let timeInterval = currentWeather["time"].double {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let date = Date.init(timeIntervalSince1970: timeInterval)
            let dateString = dateFormatter.string(from: date)
            self.date = dateString
        } else {
            self.date = "--"
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
        self.weatherDescription = currentWeather["summary"].string ?? "--"
        self.icon = currentWeather["icon"].string ?? "--"
    }
    override init() {
        
    }
    func toCelsius(_ temperature: Float) -> Float{
      return  5 * (temperature - 32)/9
    }
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.temperature, forKey: "temperature")
        aCoder.encode(self.weatherDescription, forKey: "weatherDescription")
        aCoder.encode(self.icon, forKey: "icon")
        aCoder.encode(self.windSpeed, forKey: "windSpeed")
        aCoder.encode(self.windDirection, forKey: "windDirection")
        aCoder.encode(self.feellingTemperature, forKey: "feellingTemperature")
    }
    required init?(coder aDecoder: NSCoder) {
        self.temperature = aDecoder.decodeObject(forKey: "temperature") as? String
        self.weatherDescription = aDecoder.decodeObject(forKey: "weatherDescription") as? String
        self.icon = aDecoder.decodeObject(forKey: "icon") as? String
        self.windSpeed = aDecoder.decodeObject(forKey: "windSpeed") as? String
        self.windDirection = aDecoder.decodeObject(forKey: "windDirection") as? Int
        self.feellingTemperature = aDecoder.decodeObject(forKey: "feellingTemperature") as? String
    }
}
