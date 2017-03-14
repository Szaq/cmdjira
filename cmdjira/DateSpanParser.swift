//
//  DateSpanParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

//Parses only single-entry forms of Date Span
struct DateSpanParser: ArgumentParser {
    let name: String
    var description: String? { return "Can be one of [today, yesterday, current-week, next-week] or be in form 'yyyy-mm-dd' or 'yyyy-mm-dd yyyy-mm-dd'" }
    var completions: [String] { return ["today", "yesterday", "current-week", "next-week"]}

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return DateSpan.parse(commandLineArgs: [argument])
    }

}
