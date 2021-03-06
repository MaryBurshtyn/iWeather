import UIKit
import CoreLocation
protocol SavedLocationsViewControllerDelegate: AnyObject {
    func reloadCollectionOfWeatherData()
    func displayCity(_ indexPath: IndexPath)
}
class SavedLocationsViewController: UIViewController {
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var savedLocationsTableView: UITableView!
    weak var delegate: SavedLocationsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bgImage = UIImage(named: "default.jpg"){
            self.view.backgroundColor = UIColor(patternImage: bgImage)
        }
        self.navigationController?.navigationBar.isHidden = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func addCityButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as? AddLocationViewController else {
            return
        }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.reloadCollectionOfWeatherData()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            self.delegate?.reloadCollectionOfWeatherData()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SavedLocationsViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedLocationTableViewCell", for: indexPath) as? SavedLocationTableViewCell else {
            return UITableViewCell()
        }
        guard let city = DataManager.shared.getItem(at: indexPath.row).city,
            let currentWeatherData = DataManager.shared.getItem(at: indexPath.row).currentWeatherData,
            let temperature = currentWeatherData.temperature,
            let icon =  currentWeatherData.icon else {
            return UITableViewCell()
        }
        cell.setupCell(city, temperature, icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        var newIndexPath = indexPath
        newIndexPath.row += 1
        selectedCell.contentView.backgroundColor = UIColor(red:0.45, green:0.60, blue:0.82, alpha:1.0)
        self.delegate?.reloadCollectionOfWeatherData()
        self.delegate?.displayCity(newIndexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.shared.remove(at: indexPath.row)
            self.savedLocationsTableView.deleteRows(at: [indexPath], with: .automatic)
            self.delegate?.reloadCollectionOfWeatherData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
}

extension SavedLocationsViewController: AddLocationViewControllerDelegate {
    func reloadSavedLocations() {
        savedLocationsTableView.reloadData()
        self.delegate?.reloadCollectionOfWeatherData()
    }
}
