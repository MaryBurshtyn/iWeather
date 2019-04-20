import Foundation
import MapKit

typealias JSONDictionary = [String:Any]

class LocationServices {
    
    static let shared = LocationServices()
    let locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let authStatus = CLLocationManager.authorizationStatus()
    let inUse = CLAuthorizationStatus.authorizedWhenInUse
    let always = CLAuthorizationStatus.authorizedAlways
    
    func getCityAndCoords(completion: @escaping (_ address: JSONDictionary?, _ latitude: String, _ longitude: String,  _ error: Error?) -> ()) {
        
        self.locManager.requestWhenInUseAuthorization()
        
        if self.authStatus == inUse || self.authStatus == always {
            
            self.currentLocation = locManager.location
             //CLLocation(latitude: 53.9, longitude: 27.56) - Minsk coords
            
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(self.currentLocation) { placemarks, error in
                
                if let occurredError = error {
                    
                    completion(nil,"","", occurredError)
                    
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

    
}
