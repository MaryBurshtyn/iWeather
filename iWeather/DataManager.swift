import Foundation
enum OperationType{
    case insert
    case removeAndInsert
    case append
}
class DataManager{
    static let shared = DataManager()
    private var weatherData = [WeatherData]()
    
    func save(weatherData data: WeatherData, operationType: OperationType, at index: Int){
        switch operationType {
        case .append:
            weatherData.append(data)
        case .insert:
            weatherData.insert(data, at: index)
        case .removeAndInsert:
            weatherData.insert(data, at: index)
            weatherData.remove(at: index + 1)
        }
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: weatherData)
        UserDefaults.standard.set(encodedData, forKey: "userLocations")
    }
    
    func fetchWeatherData()-> [WeatherData]{
        guard let userDefaultsData = UserDefaults.standard.object(forKey: "userLocations") as? Data, let savedLocations = NSKeyedUnarchiver.unarchiveObject(with: userDefaultsData) as? [WeatherData] else {
            return []
        }
        if  savedLocations.count != 0{
            return savedLocations
        } else {
            return []
        }
    }
    func remove(at index:Int){
        weatherData.remove(at: index)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: weatherData)
        UserDefaults.standard.set(encodedData, forKey: "userLocations")
    }
    
    func count() -> Int {
        return weatherData.count
    }
    
    func getItem(at index: Int) -> WeatherData {
        return weatherData[index]
    }
}
