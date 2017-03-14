//
//  DateParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct DateParser: ArgumentParser {
    let name: String
    var description: String? { return "Can be one of [today, yesterday] or be in form 'yyyy-mm-dd'" }
    var completions: [String] { return ["today", "yesterday"]}

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return Date.parse(string: argument)
    }
}
