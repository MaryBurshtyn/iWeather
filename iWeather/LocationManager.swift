/*import Foundation
import CoreLocation
import MapKit
protocol LocationManagerDelegate: AnyObject {
    func reloadCollectionView()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    let locManager = CLLocationManager()
    var currentLocation: CLLocation!
    weak var delegate: LocationManagerDelegate?
    
    let authStatus = CLLocationManager.authorizationStatus()
    let inUse = CLAuthorizationStatus.authorizedWhenInUse
    let always = CLAuthorizationStatus.authorizedAlways
    
    func getCityAndCoords(completion: @escaping (_ address: JSONDictionary?, _ latitude: String, _ longitude: String,  _ error: Error?) -> ()) {
        self.locManager.requestWhenInUseAuthorization()
        if self.authStatus == inUse || self.authStatus == always {
            self.currentLocation = locManager.location

            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.currentLocation) { placemarks, error in
                if let e = error {
                    completion(nil,"","", e)
                } else {
                    let placeArray = placemarks as? [CLPlacemark]
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    guard let address = placeMark.addressDictionary as? JSONDictionary else {
                        return
                    }
                    let longitude = String(self.currentLocation.coordinate.longitude)
                    let latitude = String(self.currentLocation.coordinate.latitude)
                    completion(address,latitude,longitude, nil)
                }
            }
        }
    }
    
    func updateLocation(){
        locManager.startUpdatingLocation()
    }
    func isAutorized() -> Bool{
        self.locManager.requestWhenInUseAuthorization()
        return self.authStatus == inUse || self.authStatus == always
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        getCityAndCoords { [weak self] address, latitude, longitude, error in
            DispatchQueue.main.async {
                guard let a = address, let city = a["City"] as? String else {
                    return
                }
                DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                    if let weatherData = weatherData {
                        print(weatherData)
                        if DataManager.shared.count() != 0, DataManager.shared.getItem(at: 0).city != weatherData.city {
                            
                            DataManager.shared.save(weatherData: weatherData, operationType: .insert, at: 0)
                            self?.delegate?.reloadCollectionView()
                        } else {
                            if DataManager.shared.count() == 0 {
                                DataManager.shared.save(weatherData: weatherData, operationType: .append, at: 0)
                            }else{
                                DataManager.shared.save(weatherData: weatherData, operationType: .removeAndInsert, at: 0)
                            }
                            self?.delegate?.reloadCollectionView()
                        }
                    }
                    else if let _ = error {
                        guard let controller = self?.delegate as? WeatherViewController else {
                            return
                        }
                        DarkSkyService.handleError(message: "Unable to load the forecast for your location. Check Internet Connection", controller: controller)
                    }
                }
            }
        }
    }
}
*/
