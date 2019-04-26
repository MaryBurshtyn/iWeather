import Foundation
import SwiftyJSON

class ForecastData: NSObject, NSCoding {
    
    var temperatureMin: String?
    var temperatureMax: String?
    var date: String?
    var icon: String?

    init(data: Any, index: Int) {
        let json = JSON(data)
        let forecast = json["daily"]["data"][index+2] // +2 'couse darkSky return forecast from yesterday
        super.init()
        if let temperatureMin = forecast["temperatureMin"].float {
            self.temperatureMin = String(format: "%.0f", toCelsius(temperatureMin)) + " ºC"
        } else {
            self.temperatureMin = "--"
        }
        if let timeInterval = forecast["time"].double {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"
            let date = Date.init(timeIntervalSince1970: timeInterval)
            let dateString = dateFormatter.string(from: date)
            self.date = dateString
        } else {
            self.date = "--"
        }
        if let temperatureMax = forecast["temperatureMax"].float {
            self.temperatureMax = String(format: "%.0f", toCelsius(temperatureMax)) + " ºC"
        } else {
            self.temperatureMax = "--"
        }
        self.icon = forecast["icon"].string ?? "--"
    }
    
    func toCelsius(_ temperature: Float) -> Float{
        return  5 * (temperature - 32)/9
    }
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.temperatureMin, forKey: "temperatureMin")
        aCoder.encode(self.temperatureMax, forKey: "temperatureMax")
        aCoder.encode(self.icon, forKey: "icon")
    }
    required init?(coder aDecoder: NSCoder) {
        self.temperatureMin = aDecoder.decodeObject(forKey: "temperatureMin") as? String
        self.temperatureMax = aDecoder.decodeObject(forKey: "temperatureMax") as? String
        self.icon = aDecoder.decodeObject(forKey: "icon") as? String
    }
    
}
