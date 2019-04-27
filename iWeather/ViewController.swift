import UIKit
import CoreLocation
import MapKit
//parallax https://www.sitepoint.com/using-uikit-dynamics-swift-animate-apps/
class ViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    var menuButton: UIButton = UIButton()
    var vSpinner : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner(onView: self.view)
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        collectionView.isPagingEnabled = true
        setUpMenuButton(menuButton)
        menuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(menuButton)
        self.view.bringSubview(toFront: menuButton)
        self.navigationController?.navigationBar.isHidden = true
//-------------------get current location and weather forecast--------------------
        LocationServices.shared.getCityAndCoords { [weak self] address, latitude, longitude, error in
            DispatchQueue.main.async {
                guard let a = address, let city = a["City"] as? String else {
                    return
                }
                DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                    if let weatherData = weatherData {
                        print(weatherData)
                        DataManager.shared.weatherData.insert(weatherData, at: 0)
                        self?.removeSpinner()
                        self?.collectionView.reloadData()
                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: DataManager.shared.weatherData)
                        UserDefaults.standard.set(encodedData, forKey: "userLocations")
                    }
                    else if let _ = error {
                        guard let controller = self else {
                            return
                        }
                        DarkSkyService.handleError(message: "Unable to load the forecast for your location.", controller: controller)
                    }
                }
            }
        }
//------------------get user defaults and update forecast for saved locations------------
        guard let userDefaultsData = UserDefaults.standard.object(forKey: "userLocations") as? Data, let savedLocations = NSKeyedUnarchiver.unarchiveObject(with: userDefaultsData) as? [RequiredData] else {
            return
        }
        if  savedLocations.count != 0 {
            var locations = savedLocations
            locations.remove(at: 0)
            for location in locations{
                guard let latitude = location.latitude,
                    let longitude = location.longitude,
                    let city = location.city else {
                        return
                }
                DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                    DispatchQueue.main.async {
                        if let updatedData = weatherData {
                            DataManager.shared.weatherData.append(updatedData)
                            self.collectionView.reloadData()
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: DataManager.shared.weatherData)
                            UserDefaults.standard.set(encodedData, forKey: "userLocations")
                        }
                        else if let _ = error {
                            DarkSkyService.handleError(message: "Unable to load the forecast for your location.", controller: self)
                        }
                    }
                }
            }
        }
    }

    @objc func buttonAction(sender: UIButton!) {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SavedLocationsViewController") as? SavedLocationsViewController else {
            return
        }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setUpMenuButton(_ button: UIButton){
        let size = 50
        button.frame = UIButton(frame: CGRect(x: 15 , y: 20, width: size, height: size)).frame
        button.setImage(UIImage(named: "menu.png"), for: .normal)
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
        let data = DataManager.shared.weatherData[indexPath.row]
        cv.setUpCell(data, viewController)
        return cv
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
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
    func displayCity(_ indexPath: IndexPath) {
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically,   .centeredHorizontally], animated: true)
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
