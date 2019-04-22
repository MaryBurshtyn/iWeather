import UIKit
import CoreLocation
import MapKit
//parallax https://www.sitepoint.com/using-uikit-dynamics-swift-animate-apps/
class ViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    var vSpinner : UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner(onView: self.view)
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        collectionView.isPagingEnabled = true
        
       if let savedLocations = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "userLocations") as! Data) as? [RequiredData]  {

            DataManager.shared.weatherData = savedLocations
            updateData()
            self.collectionView.reloadData()
            self.removeSpinner()
            LocationServices.shared.getCityAndCoords {[weak self] address, latitude, longitude, error in
                DispatchQueue.main.async {
                    guard let a = address, let city = a["City"] as? String else {
                        return
                    }
                    if DataManager.shared.weatherData[0].city != city{
                        guard let updatedWeather = self?.getForecast(latitude, longitude, city) as? RequiredData else {
                            return
                        }
                        DataManager.shared.weatherData.insert(updatedWeather, at: 0)
                        DataManager.shared.weatherData.remove(at: 1)
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
       else {
            LocationServices.shared.getCityAndCoords {[weak self] address, latitude, longitude, error in
                DispatchQueue.main.async {
                    guard let a = address, let city = a["City"] as? String else {
                        return
                    }
                    DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                        if let weatherData = weatherData {
                            print(weatherData)
                            self?.removeSpinner()
                            DataManager.shared.weatherData.append(weatherData)
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: DataManager.shared.weatherData)
                            UserDefaults.standard.set(encodedData, forKey: "userLocations")
                        }
                        else if let _ = error {
                            guard let controller = self else {
                                return
                            }
                            DarkSkyService.handleError(message: "Unable to load the forecast for your location.", controller: controller)
                        }
                        self?.collectionView.reloadData()
                    }
                    
                }
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SavedLocationsViewController") as? SavedLocationsViewController else {
            return
        }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func updateData(){
        var index = 0
        for location in DataManager.shared.weatherData {
            guard let latitude = location.latitude,
                let longitude = location.longitude,
                let city = location.city else {
                    return
            }
            guard let updatedWeather = getForecast(latitude, longitude, city) as? RequiredData else {
                return
            }
            DataManager.shared.weatherData.insert(updatedWeather, at: index)
            DataManager.shared.weatherData.remove(at: index + 1)
            index += 1
        }
    }
    func getCurrentLocation(){
        LocationServices.shared.getCityAndCoords {[weak self] address, latitude, longitude, error in
            DispatchQueue.main.async {
                guard let a = address, let city = a["City"] as? String else {
                    return
                }
            }
        }
    }
    func getForecast(_ latitude: String, _ longitude: String, _ city: String) -> Any? {
        var requiredData: Any?
        DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
            if let weatherData = weatherData {
                print(weatherData)
                requiredData = weatherData
            }
            else if let _ = error {
                //self?.handleError(message: "Unable to load the forecast for your location.")
                DarkSkyService.handleError(message: "Unable to load the forecast for your location.", controller: self)
            }
        }
        return requiredData
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.shared.weatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cv = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCollectionViewCell", for: indexPath) as? CityCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildViewController") as? ChildViewController else {
            return UICollectionViewCell()
        }
        display(contentController: viewController, on: cv.contentView)
        guard let currentWeather = DataManager.shared.weatherData[indexPath.row].currentWeatherData else {
            return UICollectionViewCell()
        }
        cv.setUpCell(currentWeather.temperature, viewController)
        return cv
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let city = DataManager.shared.weatherData[indexPath.row].city else {
            return
        }
        self.navigationController?.navigationBar.topItem?.title = city
        self.view.reloadInputViews()
    }
   
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.navigationController?.navigationBar.topItem?.title = DataManager.shared.weatherData[indexPath.row].getCity()
    }
    func display(contentController content: UIViewController, on view: UIView) {
        self.addChildViewController(content)
        content.view.frame = view.bounds
        view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
}
extension ViewController: SavedLocationsViewControllerDelegate {
    func reloadCollectionOfWeatherData() {
        let w = DataManager.shared.weatherData
        print(w)
        self.collectionView.reloadData()
    }
}
extension ViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}
