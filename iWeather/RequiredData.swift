import Foundation
import SwiftyJSON

class RequiredData: NSObject, NSCoding {
    
    var city: String?
    var latitude: String?
    var longitude: String?
    var currentWeatherData: CurrentWeatherData?
    var forecastData: [ForecastData] = []
    
    init(data: Any, _ latitude: String, _ longitude: String, _ city: String) {
        super.init()
        currentWeatherData = CurrentWeatherData(data: data)
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        for i in 0...5{
            forecastData.append(ForecastData(data: data, index: i))
        }
    }
    func getCity() -> String {
        guard let city = self.city else {
            return "Unknown city"
        }
        return city
    }
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.currentWeatherData, forKey: "currentWeatherData")
        aCoder.encode(self.forecastData, forKey: "forecastData")
    }
    required init?(coder aDecoder: NSCoder) {
        self.city = aDecoder.decodeObject(forKey: "city") as? String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? String
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? String
        self.currentWeatherData = aDecoder.decodeObject(forKey: "currentWeatherData") as? CurrentWeatherData ?? CurrentWeatherData()
        self.forecastData = aDecoder.decodeObject(forKey: "forecastData") as? [ForecastData] ?? []
    }
}
