//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by owner on 4/16/19.
//  Copyright © 2019 owner. All rights reserved.
//

import UIKit
import MapKit

protocol AddLocationViewControllerDelegate: AnyObject {
    func reloadSavedLocations()
}

class AddLocationViewController: UIViewController {
    
    weak var delegate: AddLocationViewControllerDelegate?
    var matchingItems: [MKMapItem] = []
    let locationManager = CLLocationManager()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        print(selectedItem.coordinate)
        guard let city = selectedItem.name else {
            return
        }
        let latitude =  String(selectedItem.coordinate.latitude)
        let longitude =  String(selectedItem.coordinate.longitude)
        DarkSkyService.weatherForCoordinates(latitude, longitude, city) {[weak self] weatherData, error in
            guard let addLocationController = self else{
                    return
            }
            if let weatherData = weatherData {
                print(weatherData)
                DataManager.shared.weatherData.append(weatherData)
                self?.delegate?.reloadSavedLocations()
                self?.navigationController?.popViewController(animated: true)
            }
            else if let _ = error {
                DarkSkyService.handleError(message: "Unable to load the forecast for your location.", controller: addLocationController)
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

