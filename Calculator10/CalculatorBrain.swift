//
//  CalculatorBrain.swift
//  Calculator10
//
//  Created by John Patton on 3/11/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    // Currently effectively unused - since it is private and there is no code in the brain to set variables
    private var variables = [String:Double]()
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private enum Operand: CustomStringConvertible {
        case number(operand: Double, description: String)
        case variable(operand: String, description: String)
        case operation(operand: Operation, description: String)
        
        var description: String {
            switch self {
            case .number(operand: _, description: let desc):
                return desc
            case .variable(operand: _, description: let desc):
                return desc
            case .operation(operand: _, description: let desc):
                return desc
            }
        }
    }
    
    private var operandStack = [Operand]()
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "∛": Operation.unaryOperation(cbrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "±": Operation.unaryOperation {-$0},
        "1/x": Operation.unaryOperation {1 / $0},
        "^2": Operation.unaryOperation {pow($0,2)},
        "^3": Operation.unaryOperation {pow($0,3)},
        "×": Operation.binaryOperation {$0 * $1},
        "÷": Operation.binaryOperation {$0 / $1},
        "+": Operation.binaryOperation {$0 + $1},
        "−": Operation.binaryOperation {$0 - $1},
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {

            operandStack.append(Operand.operation(operand: operation, description: symbol))
            print("\(operandStack)")
            
            /*let (testResult,testPending,testDesc) = evaluate()
            print("\(testResult), \(testPending), \(testDesc)")*/
            
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand,secondOperand)
        }
    }

    mutating func setOperand(_ operand: Double) {
        operandStack.append(Operand.number(operand: operand, description: "\(operand)"))
    }
    
    mutating func setOperand(variable named: String) {
        variables[named] = 0
        operandStack.append(Operand.variable(operand: named, description: named))
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var evaluateVariables = variables ?? self.variables

        var currentResult: (value: Double?, desc: String?) = (0," ")
        var pendingDesc: String?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        var resultIsPending: Bool {
            get {
                return pendingBinaryOperation != nil
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && currentResult.value != nil {
                
                // pendingDescription will be not nil if we operated on the digit since entering it, otherwise we need to pick up the digit
                currentResult.desc = currentResult.desc! + " " + (pendingDesc ?? "\(currentResult.value!)")
                
                currentResult.value = pendingBinaryOperation!.perform(with: currentResult.value!)
                pendingBinaryOperation = nil // just performed, so we are no longer in this state
                pendingDesc = nil // clear this out now that we have used it
            }
        }
        
        for op in operandStack {
            switch op {
            case .number(operand: let thisOperand, description: _):
                
                currentResult.value = thisOperand
                
                if !resultIsPending { // delay until performing if the result is pending in case we unary-operate on the number first
                    currentResult.desc = "\(thisOperand)"
                } else {
                    pendingDesc = "\(thisOperand)" // separate variable we can do things with before using to execute pending operation
                }
                
            case .variable(operand: let thisOperand, description: _):
                currentResult.value = evaluateVariables[thisOperand] ?? 0
                
                if !resultIsPending { // delay until performing if the result is pending in case we unary-operate on the number first
                    currentResult.desc = "\(thisOperand)"
                } else {
                    pendingDesc = "\(thisOperand)" // separate variable we can do things with before using to execute pending operation
                }
                
            case .operation(operand: let thisOperation, description: let thisSymbol):
                switch thisOperation {
                case .constant(let value):
                    currentResult.value = value
                    if currentResult.desc == nil || currentResult.desc == " " {
                        currentResult.desc = "\(thisSymbol)" // use description here since it is the first thing we are entering
                    } else {
                        pendingDesc = "\(thisSymbol)" // use pendingDescription so performBinaryOperation only adds it to description once
                    }
                case .unaryOperation(let function):
                    if currentResult.value != nil {
                        if resultIsPending {
                            pendingDesc = "\(thisSymbol)(\(pendingDesc!))"
                        } else {
                            currentResult.desc = "\(thisSymbol)(\(currentResult.desc!))"
                        }
                        currentResult.value = function(currentResult.value!)
                    }
                case .binaryOperation(let function):
                    if currentResult.value != nil {
                        if resultIsPending { performPendingBinaryOperation() } // this step facilitates chaining operations together
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: currentResult.value!)
                        currentResult.value = nil // in pending state so clear out accumulator
                        currentResult.desc = currentResult.desc! + " \(thisSymbol)"
                    }
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
        // finishing touches on the description to indicate to user the pending state of the brain
        let suffix = resultIsPending ? " ..." : " ="
        let descWithSuffix = currentResult.desc! + (currentResult.desc! != " " ? suffix : "")
        
        return (currentResult.value, resultIsPending, descWithSuffix)
    }
    
    mutating func resetBrain() {
        operandStack = [Operand]()
        variables = [String:Double]()
    }
    
    mutating func undo() {
        if operandStack.count > 0 {
            //print("Popping from \(operandStack)")
            let _ = operandStack.popLast()
            //print("Stack is now \(operandStack)")
        }
    }
    
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
}
