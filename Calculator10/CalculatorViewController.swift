//
//  CalculatorViewController.swift
//  Calculator10
//
//  Created by John Patton on 3/11/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping && (digit != "." || display.text!.contains(".") == false) {
            display.text = display.text! + digit
        } else {
            display.text = (digit == "." ? "0" : "") + digit
            if display.text! != "0" { userIsInTheMiddleOfTyping = true }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    private var brain = CalculatorBrain()
    private var savedVariables = [String:Double]()
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.evaluate(using: savedVariables).result {
            displayValue = result
        }
        
        descriptionDisplay.text = brain.evaluate(using: savedVariables).description

    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        savedVariables["M"] = displayValue
        if let result = brain.evaluate(using: savedVariables).result {
            displayValue = result
        }
    }
    
    @IBAction func addVariable(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            displayValue = Double(display.text!.substring(to: display.text!.index(before: display.text!.endIndex))) ?? 0
        } else {
            brain.undo()
            
            if let result = brain.evaluate(using: savedVariables).result {
                displayValue = result
            }
            
            descriptionDisplay.text = brain.evaluate(using: savedVariables).description
        }
        
    }
    
    @IBAction func clear(_ sender: UIButton) {
        
        userIsInTheMiddleOfTyping = false
        displayValue = 0
        descriptionDisplay.text = " "
        savedVariables.removeAll()
        
        brain.resetBrain()
        
    }
    
    // This function supports the graphing view
    private func setVariable(to value: Double) -> Double {
        let tempVariables = ["M": value]
        return brain.evaluate(using: tempVariables).result!
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destinationViewController = segue.destination
        
        switch segue.identifier! {
        case "showGraph":
            if let navigationController = segue.destination as? UINavigationController {
                destinationViewController = navigationController.visibleViewController ?? destinationViewController
            }
            if let graphViewController = destinationViewController as? GraphViewController, brain.evaluate(using: savedVariables).isPending == false {
                graphViewController.navigationItem.title = brain.evaluate(using: savedVariables).description
                graphViewController.graphViewFunction = setVariable(to:)
            }
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "showGraph":
            return !brain.evaluate(using: savedVariables).isPending
        default:
            return true
        }
    }
    
    
}

