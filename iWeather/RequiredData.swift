import Foundation
import SwiftyJSON

struct RequiredData {
    
    var city: String?
    var latitude: String?
    var longitude: String?
    var currentWeatherData: CurrentWeatherData
    var forecastData: [ForecastData] = []
    
    init(data: Any, _ latitude: String, _ longitude: String, _ city: String) {
        currentWeatherData = CurrentWeatherData(data: data)
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        for i in 0...6{
            forecastData.append(ForecastData(data: data, index: i))
        }
    }
    func getCity() -> String {
        guard let city = self.city else {
            return "Unknown city"
        }
        return city
    }
}
