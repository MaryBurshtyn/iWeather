
import UIKit

class ChildViewController: UIViewController {


    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        temperatureView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        cityView.backgroundColor = UIColor(white: 1, alpha: 0.0)
    }
    
    
}
