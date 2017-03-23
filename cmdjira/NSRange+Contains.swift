//
//  NSRange+Contains.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 23/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension NSRange {
    func contains(_ location: Int) -> Bool {
        return NSLocationInRange(location, self)
    }

    func intersects(with rhs: NSRange) -> Bool {
        return contains(rhs.location)
            || contains(rhs.location + rhs.length)
            || rhs.contains(location)
            || rhs.contains(location + length)
    }
}
