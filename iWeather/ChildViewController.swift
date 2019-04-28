
import UIKit

class ChildViewController: UIViewController {

    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var extendedInfoView: UIView!
    @IBOutlet weak var windVelocityLabel: UILabel!
    @IBOutlet weak var windDirectionImageView: UIImageView!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    
    @IBOutlet weak var forecastView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var plotView: UIView!
    let parallaxOffset = 30
    
    var imageView : UIImageView!
    var forecastData: [ForecastData]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(frame: CGRect(x: -parallaxOffset, y: -parallaxOffset, width: Int(self.view.frame.width) + (2*parallaxOffset), height: Int(self.view.frame.height) + (2*parallaxOffset)))
        //imageView.contentMode = .center
        addParallaxToView(vw: imageView)
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        let itemWidth = self.view.frame.width/7
        collectionViewFlowLayout.itemSize = CGSize(width: itemWidth, height: collectionView.frame.height)
        collectionView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        temperatureView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        cityView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        extendedInfoView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        forecastView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        plotView.backgroundColor = UIColor(white: 1, alpha: 0.0)
    }
    func updateForecast() {
        collectionView.reloadData()
    }
    func addParallaxToView(vw: UIView) {
        let amount = parallaxOffset
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
}

extension ChildViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fData = self.forecastData else {
            return 0
        }
        return fData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let fData = self.forecastData else {
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCollectionViewCell", for: indexPath) as? ForecastCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setUpCell(fData[indexPath.row])
        return cell
    }
    
    
}




extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
