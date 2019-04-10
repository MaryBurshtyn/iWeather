import UIKit
import CoreLocation
import MapKit
//parallax https://www.sitepoint.com/using-uikit-dynamics-swift-animate-apps/
class ViewController: UIViewController {

    @IBOutlet weak var someLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationServices.shared.getCityAndCoords {[weak self] address, latitude, longitude, error in
            DispatchQueue.main.async {
                if let a = address, let city = a["City"] as? String {
                    //self?.someLabel.text = city
                }
                DarkSkyService.weatherForCoordinates(latitude: latitude, longitude: longitude) { weatherData, error in
                    if let weatherData = weatherData {
                        print(weatherData)
                    }
                    else if let _ = error {
                        self?.handleError(message: "Unable to load the forecast for your location.")
                    }
                    
                }
            }
        }
    }
    
    func handleError(message: String) {
        let alert = UIAlertController(title: "Error Loading Forecast", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

