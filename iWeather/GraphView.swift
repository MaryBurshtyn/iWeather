
import Foundation
import UIKit
import QuartzCore

class GraphView: UIView {
    
    private var data = [[String: Int]]()
    private var context : CGContext?
    
    private let padding     : CGFloat = 30
    private var graphWidth  : CGFloat = 0
    private var graphHeight : CGFloat = 0
    private var axisWidth   : CGFloat = 0
    private var axisHeight  : CGFloat = 0
    private var everest     : CGFloat = 0
    
    // Graph Styles
    var showLines   = true
    var showPoints  = true
    var linesColor  = UIColor.lightGray
    var graphColor  = UIColor.black
    var labelFont   = UIFont.systemFont(ofSize: 10)
    var labelColor  = UIColor.black
    var xAxisColor  = UIColor.black
    var yAxisColor  = UIColor.black
    
    var xMargin         : CGFloat = 25
    var originLabelText : String?
    var originLabelColor = UIColor.black
    
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
        
        // Graph size
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
                everest = CGFloat(Int(ceilf(Float(point[currKey]!) / 25) * 25))
            }
        }
        if everest == 0 {
            everest = 25
        }
        
        
        // Draw y axis labels and lines

        
        // Lets move to the first point
        let pointPath = CGMutablePath()
        let firstPoint = data[0][data[0].keys.first!]
        let initialY : CGFloat = ceil((CGFloat(firstPoint!) * (axisHeight / everest))) - 10
        let initialX : CGFloat =  0
        pointPath.move(to: CGPoint(x: initialX, y: graphHeight - initialY))
        
        // Loop over the remaining values
        for (_, value) in data.enumerated() {
            plotPoint(point: [value.keys.first!: value.values.first!], path: pointPath)
        }
        
        // Set stroke colours and stroke the values path
        context!.addPath(pointPath)
        context!.setLineWidth(2)
        context!.setStrokeColor(graphColor.cgColor)
        context!.strokePath()
        
        // Add Origin Label
        if(originLabelText != nil) {
            let originLabel = UILabel()
            originLabel.text = originLabelText
            originLabel.textAlignment = .center
            originLabel.font = labelFont
            originLabel.textColor = originLabelColor
            originLabel.backgroundColor = backgroundColor
            originLabel.frame = CGRect(x: -2, y: graphHeight + 20, width: 40, height: 20)
            addSubview(originLabel)
        }
    }
    
    
    // Plot a point on the graph
    func plotPoint(point : [String: Int], path: CGMutablePath) {
        
        // work out the distance to draw the remaining points at
        let interval = Int(Int(graphWidth) - (2 * Int(xMargin))) / (data.count - 1)
        
        let pointValue = point[point.keys.first!]
        
        // Calculate X and Y positions
        let yposition : CGFloat = ceil((CGFloat(pointValue!) * (axisHeight / everest))) - 10
        
        var index = 0
        for (ind, value) in data.enumerated() {
            if point.keys.first! == value.keys.first! && point.values.first! == value.values.first! {
                index = ind
            }
        }
        let xposition = CGFloat(interval * index) + xMargin
        
        
        // Draw line to this value
        path.addLine(to: CGPoint(x: xposition, y: graphHeight - yposition))
        /*
        let xLabel = axisLabel(title: point.keys.first!)
        xLabel.frame = CGRect(x: xposition - 18, y: graphHeight + 20, width: 36, height: 20)
        xLabel.textAlignment = .center
        addSubview(xLabel)
        */
        if(showPoints) {
            // Add a marker for this value
            let pointMarker = valueMarker()
            pointMarker.frame = CGRect(x: xposition - 8, y: CGFloat(ceil(graphHeight - yposition) - 8), width: 16, height: 16)
            layer.addSublayer(pointMarker)
        }
    }
    
    
    // Returns an axis label
    func axisLabel(title: String) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = title as String
        label.font = labelFont
        label.textColor = labelColor
        label.backgroundColor = backgroundColor
        label.textAlignment = NSTextAlignment.right
        
        return label
    }
    
    
    // Returns a point for plotting
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
