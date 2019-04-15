import UIKit
import CoreLocation
import MapKit
//parallax https://www.sitepoint.com/using-uikit-dynamics-swift-animate-apps/
class ViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        collectionView.isPagingEnabled = true
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CityCollectionViewCell")
        LocationServices.shared.getCityAndCoords {[weak self] address, latitude, longitude, error in
            DispatchQueue.main.async {
                guard let a = address, let city = a["City"] as? String else {
                    return
                }
                DarkSkyService.weatherForCoordinates(latitude, longitude,city) { weatherData, error in
                    if let weatherData = weatherData {
                        print(weatherData)
                        DataManager.shared.weatherData.append(weatherData)
                        DataManager.shared.weatherData.append(weatherData)
                        DataManager.shared.weatherData.append(weatherData)
                    }
                    else if let _ = error {
                        self?.handleError(message: "Unable to load the forecast for your location.")
                    }
                    self?.collectionView.reloadData()
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
        self.navigationController?.pushViewController(controller, animated: true)
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
        cv.setUpCell(DataManager.shared.weatherData[indexPath.row].currentWeatherData.temperature, viewController)
        return cv
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.navigationBar.topItem?.title = String(indexPath.row)
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
    
    func handleError(message: String) {
        let alert = UIAlertController(title: "Error Loading Forecast", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


