//
//  StringParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 16/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct StringParser: ArgumentParser {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return argument
    }
}
