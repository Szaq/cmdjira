//
//  ArgumentParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

protocol ParsedValue {
    func value<T>() -> T?
}

extension ParsedValue {
    func value<T>() -> T? {
        if let t = self as? T {
            return t
        } else {
            return nil
        }
    }
}

extension TimeInterval: ParsedValue {
}

extension Date: ParsedValue {
}

extension DateSpan: ParsedValue {
}

extension String: ParsedValue {
}

protocol ArgumentParser {
    //Usually set by init
    var name: String {get}
    //ex. ["today","yesterday"]
    var completions: [String] {get}
    //ex. Date can be in form of yyyy-mm-dd, or can have values: today/yesterday
    var description: String? {get}

    func parse(_ argument: String) -> ParsedValue?
}

extension ArgumentParser {
    var completions: [String] { return [] }
    var description: String? { return nil }
}

protocol ArgumentsVariantType {
    var arguments: [ArgumentParser] {get}
    func description(forCommand: String) -> String

    func parse(_ arguments: [String]) -> Any?
    func completions(forArgumentIndex argumentIndex: Int, inArguments arguments: [String]) -> [String]
}

struct ArgumentsVariant<T>: ArgumentsVariantType {
    let arguments: [ArgumentParser]
    
    //This should return both user provided description and descriptions of arguments
    let description: String

    let map: ([ParsedValue]) -> T

    func description(forCommand command: String) -> String {
        let argumentsNames = arguments.map {"<\($0.name)>"}.joined(separator: " ")


        let argumentsDescriptions = arguments
            .map {$0.description}
            .filter {$0 != nil}
            .map {$0!}
            .joined(separator: " ")

        return "\(command) \(argumentsNames) - \(description) \(argumentsDescriptions)"
    }

    func parse(_ arguments: [String]) -> Any? {
        
        let parsedArguments = zip(self.arguments, arguments).map {$0.0.parse($0.1)}

        guard
            self.arguments.count == arguments.count,
            parsedArguments.reduce(true, {$0 && $1 != nil}) else {
            return nil
        }

        return map(parsedArguments.flatMap {$0})
    }

    func completions(forArgumentIndex argumentIndex: Int, inArguments arguments: [String]) -> [String] {

        guard argumentIndex >= 0 && argumentIndex < self.arguments.count else {
            return []
        }

        guard zip(self.arguments, arguments).prefix(argumentIndex).reduce(true, {
            $0 && $1.0.parse($1.1) != nil
        }) else {
            return []
        }

        return self.arguments[argumentIndex].completions
    }
}
