import Foundation
import SwiftyJSON

struct RequiredData {
    
    var currentWeatherData: CurrentWeatherData
    var forecastData: [ForecastData] = []
    
    init(data: Any) {
        currentWeatherData = CurrentWeatherData(data: data)
        for i in 0...6{
            forecastData.append(ForecastData(data: data, index: i))
        }
    }
}
