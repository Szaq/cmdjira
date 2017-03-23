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
        guard padWidth > 0 else { return self }
        var s = self
        for _ in 0 ..< padWidth {
            s.append(padChar)
        }

        return s
    }

    func split(atWidth width: Int) -> [String] {

        var result = [String]()
        var index: String.Index = self.startIndex
        let ansiiCodesRegex = try! NSRegularExpression(pattern: "\u{001B}\\[[0-9,\\;]*m", options: .useUnicodeWordBoundaries)
        let fullRange = NSMakeRange(0, characters.count)
        let ansiiCodes = ansiiCodesRegex.matches(in: self, options: .withoutAnchoringBounds, range: fullRange)

        while true  {

            let offset = calculateNextOffset(atIndex: index,
                                             width: width,
                                             ansiiCodes: ansiiCodes)
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

    private func calculateNextOffset(atIndex startIndex: String.Index,
                                     width: Int,
                                     ansiiCodes: [NSTextCheckingResult]) -> Int {

        let characters = self.characters

        var validEndIndex = startIndex
        var trueCharsCount = 0

        var index = validEndIndex
        while index < endIndex && trueCharsCount <= (width + 1) {

            if characters[index] != Character("\u{001B}") {
                trueCharsCount += 1
                index = self.index(after: index)
                validEndIndex = index
                continue
            }

            validEndIndex = index

            //Find end of ansii character
            while characters[index] != Character("m") && index < endIndex {
                index = self.index(after: index)
            }

            //If end not found, than this ansii character is broken
            if index == endIndex {
                break
            } else {
                //otherwise add it to substring
                validEndIndex = self.index(after: index)
                continue
            }
        }

        return distance(from: startIndex, to: validEndIndex)
    }
}

