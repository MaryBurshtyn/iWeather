import UIKit
import MapKit

protocol AddLocationViewControllerDelegate: AnyObject {
    func reloadSavedLocations()
}

class AddLocationViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: AddLocationViewControllerDelegate?
    var matchingItems: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        guard let bgImage = UIImage(named: "default.jpg") else {
            return
        }
        self.view.backgroundColor = UIColor(patternImage: bgImage)
    }
}

extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell else {
            return UITableViewCell()
        }
        let selectedItem = matchingItems[indexPath.row].placemark
        guard let city = selectedItem.name else {
            return UITableViewCell()
        }
        cell.setupCell(city)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        guard let city = selectedItem.name else {
            return
        }
        let latitude =  String(selectedItem.coordinate.latitude)
        let longitude =  String(selectedItem.coordinate.longitude)
        DarkSkyService.weatherForCoordinates(latitude, longitude, city) {[weak self] weatherData, error in
            guard let self = self else{
                    return
            }
            if let weatherData = weatherData {
                DataManager.shared.save(weatherData: weatherData, operationType: .append, at: 0)
                self.delegate?.reloadSavedLocations()
                self.navigationController?.popViewController(animated: true)
            }
            else if let _ = error {
                DarkSkyService.handleError(message: "Unable to load the forecast for your location. Check Internet Connection", controller: self)
            }
        }
    }
}

extension AddLocationViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

