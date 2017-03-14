//
//  UI.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

class UI {
    private let options: CommandLineOptions

    init(options: CommandLineOptions) {
        self.options = options
    }

    func printInformation(_ text: String) {
        Swift.print(text)
    }

    func printSuccess(_ description: String? = nil) {
        let text = description ?? "OK"
        print("✅  \(text)".color(.green))
    }

    func printError(_ description: String, error: Error? = nil) {
        print("💥  \(description)".color(.red))
        if options.showErrorDetails.wasSet {
            let errorString = error.map {"\($0)"} ?? ""
            print("\(errorString)".color(.red))
        }
    }

    func printRaw(_ text: String) {
        print(text.color(.darkGray))
    }

    func printTable(rows: [[String]]) {
        var maxColLengths: [Int] = []
        for row in rows {
            for (colIndex, col) in row.enumerated() {

                if colIndex >= maxColLengths.count {
                    maxColLengths.append(0)
                }

                maxColLengths[colIndex] = max(col.utf8.count,maxColLengths[colIndex])
            }
        }

        for row in rows {
            for (colIndex, col) in row.enumerated() {
                print(col.padded(toWidth: maxColLengths[colIndex]), terminator: " ")
            }
            print("")
        }

    }

}
