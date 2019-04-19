import UIKit

class SavedLocationsViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func addCityButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as? AddLocationViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
