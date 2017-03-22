//
//  Array+Unique.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func unique() -> Array<Element> {
        let set = Set(self)
        return Array(set)
    }
}
