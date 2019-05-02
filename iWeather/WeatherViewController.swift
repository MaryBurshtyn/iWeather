import UIKit
import CoreLocation
import MapKit
import InfiniteCarouselCollectionView

typealias JSONDictionary = [String:Any]

class WeatherViewController:  UIViewController, UICollectionViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let refreshControl = UIRefreshControl()
    var menuButton: UIButton = UIButton()
    var vSpinner : UIView?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentAuthStatus: CLAuthorizationStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setUpCollectionView()
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        showSpinner(onView: self.view)
        setUpMenuButton(menuButton)
        menuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(menuButton)
        self.view.bringSubview(toFront: menuButton)
        self.navigationController?.navigationBar.isHidden = true
    }

    @objc func buttonAction(sender: UIButton!) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SavedLocationsViewController") as? SavedLocationsViewController else {
            return
        }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        updateWeather(operationType: .removeAndInsert)
    }
    
    func setUpCollectionView(){
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        collectionView.isPagingEnabled = true
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }

    func setUpMenuButton(_ button: UIButton){
        let size = 40
        button.frame = UIButton(frame: CGRect(x: 15 , y: 30, width: size, height: size)).frame
        button.setImage(UIImage(named: "menu.png"), for: .normal)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        self.currentLocation = locations.last
        getCityAndCoords { [weak self] address, latitude, longitude, error in
            DispatchQueue.main.async {
                guard let a = address, let city = a["City"] as? String else {
                    return
                }
                DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                    if let weatherData = weatherData {
                        if DataManager.shared.count() != 0, DataManager.shared.getItem(at: 0).city != weatherData.city {
                            
                            DataManager.shared.save(weatherData: weatherData, operationType: .insert, at: 0)
                            self?.removeSpinner()
                            self?.collectionView.reloadData()
                        } else {
                            if DataManager.shared.count() == 0 {
                                DataManager.shared.save(weatherData: weatherData, operationType: .append, at: 0)
                            }else{
                                DataManager.shared.save(weatherData: weatherData, operationType: .removeAndInsert, at: 0)
                            }
                            self?.removeSpinner()
                            self?.collectionView.reloadData()
                        }
                        self?.collectionView.contentOffset.x = 0
                        self?.collectionView.reloadData()
                    }
                    else if let _ = error {
                        guard let controller = self else {
                            return
                        }
                        DarkSkyService.handleError(message: "Unable to load the forecast for your location. Check Internet Connection", controller: controller)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse, CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
            guard self.currentAuthStatus != nil else {
                currentAuthStatus = CLLocationManager.authorizationStatus()
                manager.requestAlwaysAuthorization()
                return
            }
            self.removeSpinner()
            let alert = UIAlertController(title: "Couldn't get current location.", message: "Please cange your privacy settings", preferredStyle:  .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction!) -> Void in
                let savedLocations = DataManager.shared.fetchWeatherData()
                if savedLocations.count == 0 {
                    guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SavedLocationsViewController") as? SavedLocationsViewController else {
                        return
                    }
                    controller.delegate = self
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else {
                    self.updateWeather(operationType: .append)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            updateWeather(operationType: .append)
            currentAuthStatus = CLLocationManager.authorizationStatus()
        }
    }
    
    func getCityAndCoords(completion: @escaping (_ address: JSONDictionary?, _ latitude: String, _ longitude: String,  _ error: Error?) -> ()) {
        if  CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.currentLocation) { placemarks, error in
                if let occurredError = error {
                    completion(nil,"","", occurredError)
                } else {
                    let placeArray = placemarks
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
    
    func updateWeather(operationType: OperationType){
        locationManager.startUpdatingLocation()
        var savedLocations = DataManager.shared.fetchWeatherData()
        if savedLocations.count == 0 {
            return
        }
        if  CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            savedLocations.remove(at: 0)
        }
        var index = 1
        for location in savedLocations{
            guard let latitude = location.latitude,
                let longitude = location.longitude,
                let city = location.city else {
                    return
            }
            DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                DispatchQueue.main.async {
                    if let updatedData = weatherData {
                        DataManager.shared.save(weatherData: updatedData, operationType: operationType , at: index)
                        if index == DataManager.shared.count() - 1{
                            self.refreshControl.endRefreshing()
                            self.removeSpinner()
                        }
                        index += 1
                        self.collectionView.reloadData()
                    }
                    else if let _ = error {
                        DarkSkyService.handleError(message: "Unable to load the forecast for your location. Check Internet Connection", controller: self)
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.reloadInputViews()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if DataManager.shared.count() > 1{
            if indexPath.row == 0 {
                var newIndexPath = indexPath
                newIndexPath.row = DataManager.shared.count()
                self.collectionView.scrollToItem(at: newIndexPath, at: [.centeredVertically,   .centeredHorizontally], animated: true)
            }
            if indexPath.row == DataManager.shared.count() + 1 {
                var newIndexPath = indexPath
                newIndexPath.row = 1
                self.collectionView.scrollToItem(at: newIndexPath, at: [.centeredVertically,   .centeredHorizontally], animated: true)
            }
        }
        
    }
   
    func display(contentController content: UIViewController, on view: UIView) {
        self.addChildViewController(content)
        content.view.frame = view.bounds
        view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
}

extension WeatherViewController: SavedLocationsViewControllerDelegate {
    func reloadCollectionOfWeatherData() {
        self.collectionView.reloadData()
    }
    func displayCity(_ indexPath: IndexPath) {
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically,   .centeredHorizontally], animated: true)
    }
}

extension WeatherViewController {
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
extension WeatherViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if DataManager.shared.count() > 1 {
            return DataManager.shared.count() + 2
        }
        return DataManager.shared.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cv = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCollectionViewCell", for: indexPath) as? CityCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildViewController") as? ChildViewController else {
            return UICollectionViewCell()
        }
        display(contentController: viewController, on: cv.contentView)
        if indexPath.row == 0{
            let data = DataManager.shared.getItem(at: indexPath.row)
            cv.setUpCell(data, viewController)
            return cv
        }
        if indexPath.row == DataManager.shared.count() + 1{
            let data = DataManager.shared.getItem(at: indexPath.row - 2)
            cv.setUpCell(data, viewController)
            return cv
        }
        let data = DataManager.shared.getItem(at: indexPath.row - 1)
        cv.setUpCell(data, viewController)
        return cv
    }
    
}
