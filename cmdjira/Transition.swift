//
//  Transition.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct Transition {
    let json: JSON

    var name: String { return json["name"].stringValue }
    var id: String { return json["id"].stringValue }
}
