//
//  DurationParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct DurationParser: ArgumentParser {
    let name: String
    var description: String? { return "Can be in form of 13:30, 51s, 23m 4h, 5d, 1w" }

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return TimeInterval(fromCommandLine: argument)
    }
}
