
import Foundation
import UIKit
import QuartzCore

class GraphView: UIView {
    
    private var data = [[String: Int]]()
    private var context : CGContext?
    
    private var graphWidth  : CGFloat = 0
    private var graphHeight : CGFloat = 0
    private var axisWidth   : CGFloat = 0
    private var axisHeight  : CGFloat = 0
    private var everest     : CGFloat = 0

    var showPoints  = true
    var linesColor  = UIColor.lightGray
    var graphColor  = UIColor.black
    var xMargin         : CGFloat = 25
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, data: [[String: Int]]) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.data = data
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        context = UIGraphicsGetCurrentContext()
        graphWidth = rect.size.width
        graphHeight = rect.size.height
        axisWidth = rect.size.width
        axisHeight = rect.size.height
        
        for (index, point) in data.enumerated() {
            let key = Array(data[index].keys)
            guard let currKey = key.first else {
                return
            }
            if CGFloat(point[currKey]!) > everest {
                everest = CGFloat(Int(ceilf(Float(point[currKey]!) / 5) * 5))
            }
        }
        if everest == 0 {
            everest = 5
        }

        let pointPath = CGMutablePath()
        let firstPoint = data[0][data[0].keys.first!]
        let initialY : CGFloat = ceil((CGFloat(firstPoint!) * (axisHeight / everest)))
        let initialX : CGFloat =  0
        pointPath.move(to: CGPoint(x: initialX, y: graphHeight - initialY))

        for (_, value) in data.enumerated() {
            plotPoint(point: [value.keys.first!: value.values.first!], path: pointPath)
        }

        context!.addPath(pointPath)
        context!.setLineWidth(2)
        context!.setStrokeColor(graphColor.cgColor)
        context!.strokePath()
        
    }
    
    func plotPoint(point : [String: Int], path: CGMutablePath) {
        
        let interval = Int(Int(graphWidth) - (2 * Int(xMargin))) / (data.count - 1)
        let pointValue = point[point.keys.first!]
        let yposition : CGFloat = ceil((CGFloat(pointValue!) * (axisHeight / everest)))
        var index = 0
        for (ind, value) in data.enumerated() {
            if point.keys.first! == value.keys.first! && point.values.first! == value.values.first! {
                index = ind
            }
        }
        let xposition = CGFloat(interval * index) + xMargin
        path.addLine(to: CGPoint(x: xposition, y: graphHeight - yposition))
        if(showPoints) {
            let pointMarker = valueMarker()
            pointMarker.frame = CGRect(x: xposition - 8, y: CGFloat(ceil(graphHeight - yposition) - 8), width: 16, height: 16)
            layer.addSublayer(pointMarker)
        }
    }

    func valueMarker() -> CALayer {
        let pointMarker = CALayer()
        pointMarker.backgroundColor = backgroundColor?.cgColor
        pointMarker.cornerRadius = 8
        pointMarker.masksToBounds = true
        
        let markerInner = CALayer()
        markerInner.frame = CGRect(x: 3, y: 3, width: 10, height: 10)
        markerInner.cornerRadius = 5
        markerInner.masksToBounds = true
        markerInner.backgroundColor = graphColor.cgColor
        
        pointMarker.addSublayer(markerInner)
        
        return pointMarker
    }
}
