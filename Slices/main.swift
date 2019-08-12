//
//  main.swift
//  Slices
//
//  Created by Eric Mentele on 8/8/19.
//  Copyright © 2019 Eric Mentele. All rights reserved.
//

/*
 Coding Challenge
 
 Write a command line program in the language of your choice that will take operations on fractions as an input and produce a fractional result.
 Legal operators shall be *, /, +, - (multiply, divide, add, subtract)
 Operands and operators shall be separated by one or more spaces
 Mixed numbers will be represented by whole_numerator/denominator. e.g. "3_1/4"
 Improper fractions and whole numbers are also allowed as operands
 Example run:
 ? 1/2 * 3_3/4
 = 1_7/8
 
 ? 2_3/8 + 9/8
 = 3_1/2
 */

import Foundation

// MARK: - Variables & Functions

enum ValidOperators: String {
    case multiply = "*"
    case divide = "/"
    case add = "+"
    case subtract = "-"
}

struct Operation {
    var type: ValidOperators!
    var leftNumber: Double
    var rightNumber: Double
}

// https://stackoverflow.com/questions/35895154/decimal-to-fraction-conversion-in-swift
// Note: This code for converting a remainder to a fraction came from the above link because after looking into it, accurately making the fraction is pretty tricky. I figured that in real life we use resources like these as long as we are carful to test that they work correctly. If this is unacceptable for this challenge, even though there was no stated restriction, I will roll my own algorithm by converting something like this to code: https://www.mathsisfun.com/converting-decimals-fractions.html
typealias Rational = (num : Int, den : Int)

func rationalApproximationOf(x0 : Double, withPrecision eps : Double = 1.0E-6) -> Rational {
    var x = x0
    var a = floor(x)
    var (h1, k1, h, k) = (1, 0, Int(a), 1)
    
    while x - a > eps * Double(k) * Double(k) {
        x = 1.0/(x - a)
        a = floor(x)
        (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
    }
    return (h, k)
}

func solve(equation: String) -> String {
    let cleanedEquation = clean(input: equation)
    guard validate(input: cleanedEquation) else { fatalError("Invalid argument. Example input: 1/2 * 3_3/4. Legal operators: *, /, -, +")}
    let components = cleanedEquation.components(separatedBy: " ")
    let solution = solve(equation: components)
    return convertToFractionalNumberString(number: solution)
}

func clean(input: String) -> String {
    var cleaned = input
    var index = cleaned.startIndex
    
    while index < cleaned.endIndex {
        if cleaned[index] == " " && index != cleaned.index(before: cleaned.endIndex) && cleaned[cleaned.index(after: index)] == " " {
            cleaned.remove(at: index)
        } else {
            index = cleaned.index(after: index)
        }
    }
    
    return cleaned
}

func validate(input: String) -> Bool {
    guard input != "" else { return false }
    let components = clean(input: input).components(separatedBy: " ")
    guard !(components.count % 2 == 0) else { return false }
    
    var operatorComponent = false
    
    for component in components {
        if operatorComponent {
            guard component == ValidOperators.subtract.rawValue ||
                component == ValidOperators.divide.rawValue ||
                component == ValidOperators.multiply.rawValue ||
                component == ValidOperators.add.rawValue else { return false }
        } else {
            if component.contains("_") { guard component.contains("/") else { return false }}
        }
        operatorComponent = !operatorComponent
    }
    
    return true
}

func solve(equation components: [String]) -> Double {
    if components.count == 1 {
        return convertToDouble(number: components[0])
    }
    
    if components.contains(ValidOperators.subtract.rawValue) {
        for (index, component) in components.enumerated() {
            if component == ValidOperators.subtract.rawValue {
                let firstHalf = Array(components[0..<index])
                let secondHalf = Array(components[index + 1..<components.count])
                return solve(equation: firstHalf) - solve(equation: secondHalf)
            }
        }
    } else if components.contains(ValidOperators.add.rawValue) {
        for (index, component) in components.enumerated() {
            if component == ValidOperators.add.rawValue {
                let firstHalf = Array(components[0..<index])
                let secondHalf = Array(components[index + 1..<components.count])
                return solve(equation: firstHalf) + solve(equation: secondHalf)
            }
        }
    } else if components.contains(ValidOperators.divide.rawValue) {
        for (index, component) in components.enumerated() {
            if component == ValidOperators.divide.rawValue {
                let firstHalf = Array(components[0..<index])
                let secondHalf = Array(components[index + 1..<components.count])
                return solve(equation: firstHalf) / solve(equation: secondHalf)
            }
        }
    } else if components.contains(ValidOperators.multiply.rawValue) {
        for (index, component) in components.enumerated() {
            if component == ValidOperators.multiply.rawValue {
                let firstHalf = Array(components[0..<index])
                let secondHalf = Array(components[index + 1..<components.count])
                return solve(equation: firstHalf) * solve(equation: secondHalf)
            }
        }
    }
    
    return 0.0
}

func convertToDouble(number: String) -> Double {
    let numberComponents = number.components(separatedBy: "_")
    var wholeNumber: Double = 0.0
    let fractionComponents = numberComponents.count == 1 ? numberComponents[0].components(separatedBy: "/") : numberComponents[1].components(separatedBy: "/")
    
    if fractionComponents.count == 1 {
        return Double(fractionComponents[0]) ?? 0.0
    }
    
    if numberComponents.count > 1 {
        wholeNumber = Double(numberComponents[0]) ?? 0.0
    }
    
    let numerator = Double(fractionComponents[0]) ?? 0.0
    let denominator = Double(fractionComponents[1]) ?? 0.0
    let DoubleForFraction = numerator / denominator
    return wholeNumber + DoubleForFraction
}

func convertToFractionalNumberString(number: Double) -> String {
    let wholeNumber = Int(number)
    let remainder = number - Double(wholeNumber)
    
    if remainder == 0 {
        return "\(wholeNumber)"
    }
    
    let fraction = rationalApproximationOf(x0: remainder)
    
    if wholeNumber == 0 {
        return "\(fraction.num)/\(fraction.den)"
    }
    
    return "\(wholeNumber)_\(fraction.num)/\(fraction.den)"
}

// MARK: - TESTS
func doTests() {
    let convertToDoubleTestCases: [(test: String, answer: Double)] = [("1/2",0.5),
                                                                      ("1", 1.0),
                                                                      ("1_1/2", 1.5)]
    
    for test in convertToDoubleTestCases {
        assert(convertToDouble(number: test.test) == test.answer)
    }
    
    let solutionTestCases: [(test: String, answer: String)] = [("1/2 * 3_3/4", "1_7/8"),
                                                               ("2_3/8 + 9/8", "3_1/2"),
                                                               ("1_1/2 + 1 * 2", "3_1/2"),
                                                               ("1_1/2 + 3 * 2_1/4 - 1/2 / 2", "8"),
                                                               ("1/2 + 1/4", "3/4")]
    
    for test in solutionTestCases {
        assert(solve(equation: test.test) == test.answer)
    }
    
    let convertToFractionalNumberStringTestCases: [(test: Double, answer: String)] = [(0.5, "1/2"),
                                                                                      (3.8, "3_4/5"),
                                                                                      (4, "4")]
    
    for test in convertToFractionalNumberStringTestCases {
        assert(convertToFractionalNumberString(number: test.test) == test.answer)
    }
    
    let validateTestCases: [(test: String, answer: Bool)] = [("1/2 * 3_3/4", true),
                                                             ("2_3/8 % 9/8", false),
                                                             ("1_1/2 + / 1 * 2", false),
                                                             ("1_1/2 + 3 2_1/4 - 1/2 / 2", false),
                                                             ("1/2 + 2_14", false)]
    
    for test in validateTestCases {
        assert(validate(input: test.test) == test.answer)
    }
    
    let cleanTestCases: [(test: String, answer: String)] = [("1/2   *  3_3/4", "1/2 * 3_3/4"),
                                                            ("1_1/2    + 3 *   2_1/4   -   1/2  / 2", "1_1/2 + 3 * 2_1/4 - 1/2 / 2")]
    for test in cleanTestCases {
        assert(clean(input: test.test) == test.answer)
    }
    
    print("All tests passed!")
}

// MARK: - Program Execution
if CommandLine.arguments.count == 1 {
    print("Enter your fraction operation string...")
}

if CommandLine.arguments.count > 1 {
    let operation = CommandLine.arguments[1]
    
    if operation == "test" {
        doTests()
    } else {
        print(solve(equation: operation))
    }
}
