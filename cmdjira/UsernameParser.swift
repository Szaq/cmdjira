//
//  UsernameParser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 16/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation


struct UsernameParser: ArgumentParser {
    let name: String
    var completions: [String] {return Users().users.map {$0.username}}

    init(_ name: String) {
        self.name = name
    }

    func parse(_ argument: String) -> ParsedValue? {
        return argument
    }
}
