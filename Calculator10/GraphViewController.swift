//
//  GraphViewController.swift
//  Calculator10
//
//  Created by John Patton on 3/30/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            
            // Pinch to scale
            let pinchHandler = #selector(GraphView.zoomGraph(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            
            // Pan to move
            let panHandler = #selector(GraphView.moveGraph(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
            
            // Double tap to set origin
            let tapHandler = #selector(GraphView.moveOrigin(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            graphView.addGestureRecognizer(tapRecognizer)
            
        }
    }
    
    var graphViewFunction: ((Double) -> Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let functionToPlot = graphViewFunction {
            graphView.graphFunction = functionToPlot
        }
    }

}
