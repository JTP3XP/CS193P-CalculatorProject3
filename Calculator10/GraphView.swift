//
//  GraphView.swift
//  Calculator10
//
//  Created by John Patton on 3/30/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var graphFunction: ((Double) -> Double)? // = {$0 * -1 + 6}
    
    @IBInspectable var color = UIColor.red
    @IBInspectable var lineWidth:CGFloat = 1
    @IBInspectable var pointsPerUnit: CGFloat = 10.0 { didSet { setNeedsDisplay() } }
    
    // Optional because we wait until we are sure the view is initialized before trying to set this
    var origin: CGPoint? { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        
        origin = origin ?? convert(center, from: superview) // default to the center if we have not set it up already
        
        let axesDrawer = AxesDrawer(color: UIColor.black, contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxes(in: bounds, origin: origin!, pointsPerUnit: pointsPerUnit)
        
        color.set()
        pathForFunction().stroke()
        
    }
    
    private func pathForFunction() -> UIBezierPath {
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        let screenWidth = Int(bounds.maxX * contentScaleFactor)
        
        if let function = graphFunction {
            for pixel in 0...screenWidth {
                var pointInGraphCoordinates = CGPoint()
                pointInGraphCoordinates.x = CGFloat(pixel) / contentScaleFactor - origin!.x / pointsPerUnit
                pointInGraphCoordinates.y = CGFloat(function(Double(pointInGraphCoordinates.x)))
                let pointInViewCoordinates = pointInGraphCoordinates.translateToViewCoordinates(in: self)
                
                if pixel == 0 {
                    path.move(to: pointInViewCoordinates)
                } else {
                    path.addLine(to: pointInViewCoordinates)
                }
            }
        }
        
        return path
        
    }
    
    // MARK: Gesture Recognizers
    
    func moveGraph(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed, .ended:
            let translation = panRecognizer.translation(in: self)
            origin!.x += translation.x
            origin!.y += translation.y
            panRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
        default:
            break
        }
    }
    
    func zoomGraph(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            pointsPerUnit *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    func moveOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        // only react to a double tap
        tapRecognizer.numberOfTapsRequired = 2
        
        switch tapRecognizer.state {
        case .changed, .ended:
            let tappedLocation = tapRecognizer.location(in: self)
            origin = tappedLocation
        default:
            break
        }
    }
}

// MARK:- Extension

private extension CGPoint {
    func translateToViewCoordinates(in graphView: GraphView) -> CGPoint {
        // takes a CGPoint in the Graph coordinate system and returns the CGPoint in the view's coordinate system
        let pointInGraphCoordinates = self
        var pointInViewCoordinates = CGPoint()
        pointInViewCoordinates.x = pointInGraphCoordinates.x * graphView.pointsPerUnit + graphView.origin!.x
        pointInViewCoordinates.y = pointInGraphCoordinates.y * graphView.pointsPerUnit * -1 + graphView.origin!.y
        return pointInViewCoordinates
    }
}
