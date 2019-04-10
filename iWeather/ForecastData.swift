import Foundation
import SwiftyJSON

struct ForecastData {
    
    var temperatureMin: String?
    var temperatureMax: String?
    var icon: String?
    
    init(data: Any, index: Int) {
        let json = JSON(data)
        let forecast = json["daily"]["data"][index]
        
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
}
