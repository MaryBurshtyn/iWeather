//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by owner on 4/16/19.
//  Copyright © 2019 owner. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    var searching = false
    var searchedCity = [String]()
    var matchingItems: [MKMapItem] = []
    var citiesAmount = [String]()
    let locationManager = CLLocationManager()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
/*extension AddLocationViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        
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
    
}*/
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
/*extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell else {
            return UITableViewCell()
        }
        cell.setupCell(searchedCity[indexPath.row])
        return cell
    }
    
    
}

extension AddLocationViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCity = citiesAmount.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        tableView.reloadData()
    }
    
}
*/
