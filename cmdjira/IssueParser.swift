//
//  IssueParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct IssueParser: ArgumentParser {
    let name: String
    var completions: [String] {return IssuesCache().completions()}
    
    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return argument
    }
}
