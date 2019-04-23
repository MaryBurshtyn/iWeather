import UIKit

protocol SavedLocationsViewControllerDelegate: AnyObject {
    func reloadCollectionOfWeatherData()
}
class SavedLocationsViewController: UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var savedLocationsTableView: UITableView!
    weak var delegate: SavedLocationsViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let bgImage = UIImage(named: "default.jpg") else {
            return
        }
        titleView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        self.view.backgroundColor = UIColor(patternImage: bgImage)
        savedLocationsTableView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        self.navigationController?.navigationBar.isHidden = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
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
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            /*guard let controller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
                return
            }
            self.delegate?.reloadCollectionOfWeatherData()
            self.navigationController?.pushViewController(controller, animated: true)*/
            
        }
    }
}
extension SavedLocationsViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedLocationTableViewCell", for: indexPath) as? SavedLocationTableViewCell else {
            return UITableViewCell()
        }
        guard let city = DataManager.shared.weatherData[indexPath.row].city,
            let currentWeatherData = DataManager.shared.weatherData[indexPath.row].currentWeatherData,
            let temperature = currentWeatherData.temperature else {
            return UITableViewCell()
        }
        cell.setupCell(city, temperature)
        cell.backgroundColor = UIColor(white: 1, alpha: 0.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.shared.weatherData.remove(at: indexPath.row)
            self.savedLocationsTableView.deleteRows(at: [indexPath], with: .automatic)
             self.delegate?.reloadCollectionOfWeatherData()
        }
    }
}
extension SavedLocationsViewController: AddLocationViewControllerDelegate {
    func reloadSavedLocations() {
        savedLocationsTableView.reloadData()
    }
}
