//
//  IssueComponentParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct IssueComponentParser: ArgumentParser {
    let name: String
    var completions: [String] {return IssueComponentsCache().completions()}

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return argument
    }
}