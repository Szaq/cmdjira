//
//  NickParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 21/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct NickParser: ArgumentParser {
    let name: String
    var completions: [String] {return Users().users.flatMap {$0.name} + ["me"] + UserNicksCache().completions()}

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return argument
    }
}
