//
//  Project.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct Project {
    let json: JSON

    var name: String { return json["name"].stringValue }
    var key: String { return json["key"].stringValue }
}

extension Project: JSONDecodable {
}
