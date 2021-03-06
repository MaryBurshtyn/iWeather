import Foundation
import Alamofire

public class DarkSkyService {
    private static let apiKey = "f766abba0e1a7c5fb77edbccb28e0fa3"
    private static let baseURL = "https://api.darksky.net/forecast/"
    
    static func weatherForCoordinates(_ latitude: String, _ longitude: String, _ city: String, completion: @escaping (WeatherData?, Error?) -> ()) {
        if Connectivity.isConnectedToInternet {

            let url = baseURL + apiKey + "/\(latitude),\(longitude)" + "?exclude=hourly,minutely,flags"
            
            Alamofire.request(url).responseJSON { response in
                switch response.result {
                case .success(let result):
                    completion(WeatherData(data: result, latitude, longitude, city), nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        } else {
            completion(nil, "No Internet Connection")
        }
    }
    
    static func handleError(message: String, controller: UIViewController) {
        let alert = UIAlertController(title: "Error Loading Forecast", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

extension String: Error {}
