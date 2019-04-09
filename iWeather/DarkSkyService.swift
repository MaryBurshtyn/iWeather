import Foundation
import Alamofire

public class DarkSkyService {
    
    private static let apiKey = "f766abba0e1a7c5fb77edbccb28e0fa3"
    private static let baseURL = "https://api.darksky.net/forecast/"
    static func weatherForCoordinates(latitude: String, longitude: String, completion: @escaping (WeatherData?, Error?) -> ()) {
        
        let url = baseURL + apiKey + "/\(latitude),\(longitude)" + "?exclude=daily,hourly,minutely,flags"
        
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let result):
                completion(WeatherData(data: result), nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
//https://gtios.club/weather-part-6/
