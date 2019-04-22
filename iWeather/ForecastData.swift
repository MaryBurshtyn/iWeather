import Foundation
import SwiftyJSON

class ForecastData: NSObject, NSCoding {
    
    var temperatureMin: String?
    var temperatureMax: String?
    var icon: String?

    init(data: Any, index: Int) {
        let json = JSON(data)
        let forecast = json["daily"]["data"][index]
        super.init()
        if let temperatureMin = forecast["temperatureMin"].float {
            self.temperatureMin = String(format: "%.0f", toCelsius(temperatureMin)) + " ºC"
        } else {
            self.temperatureMin = "--"
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
