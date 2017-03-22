//
//  IssueStatusParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct IssueStatusParser: ArgumentParser {
    let name: String
    var completions: [String] {return IssueStatusesCache().completions()}
    var description: String? = "Issue status may be lowercased and spaces may be omitted."

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return argument
    }
}
