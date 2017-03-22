//
//  String+Padding.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension String {
    /**
     * Pads a string to the specified width.
     *
     * - parameter by: The width of pad.
     * - parameter by: The character to use for padding.
     *
     * - returns: A new string, padded to the given width.
     */
    func padded(by padWidth: Int, with padChar: Character = " ") -> String {
        var s = self
        for _ in 0 ..< padWidth {
            s.append(padChar)
        }

        return s
    }

    func split(atWidth width: Int) -> [String] {

        var result = [String]()
        var index: String.Index = self.startIndex
        while true  {
            let offset = min(distance(from: index, to: endIndex), width)
            if offset <= 0 {
                break
            }
            let endRangeIndex = self.index(index, offsetBy: offset)
            let range = Range(uncheckedBounds: (lower: index, upper: endRangeIndex))
            let substring = self.substring(with: range)
            result.append(substring)
            index = endRangeIndex
        }

        return result
    }

}
