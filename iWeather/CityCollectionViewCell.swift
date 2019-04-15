import Foundation
import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    
    func setUpCell(_ data: String?, _ controller: ChildViewController)  {
        controller.tempLabel.text = data
        
        if data == "15"{
            controller.view.backgroundColor = .green
        }else {
            controller.view.backgroundColor = .red
        }
    }
}
