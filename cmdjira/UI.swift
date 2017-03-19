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

    private var shouldDisplayNextActivityIndicator = false

    var isTTY: Bool { return isatty(fileno(stdin)) != 0 }

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

    func printQuestion(_ question: String) {
        print(question.bold.color(.cyan))
    }

    func startActivityIndicator() {
        guard isTTY && !options.disableSpinner.wasSet else { return }
        shouldDisplayNextActivityIndicator = true
        drawActivityIndicator(step: 0)
    }

    func stopActivityIndicator() {
        shouldDisplayNextActivityIndicator = false
    }

    private func drawActivityIndicator(step: Int) {
        guard shouldDisplayNextActivityIndicator else { return }

        let stepChar = ["/", "-", "\\", "|"][step % 4]
        print("\(stepChar)", terminator: "\r")
        fflush(__stdoutp)

        let after = DispatchTime.now() + DispatchTimeInterval.milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: after) {
            self.drawActivityIndicator(step: step + 1)
        }
    }

    func prompt(label: String, multiline: Bool = false) -> String {

        var lines = [String]()

        //Display prompt only if we are not being piped into
        if isTTY {
            printQuestion(label + (multiline ? " Enter line containing single word END to finish.".color(.cyan) : ""))
            while let line = readLine(), !multiline || line != "END" {
                lines.append(line)

                if !multiline {
                    break
                }
            }

        } else {

            while let line = readLine() {
                lines.append(line)
            }
        }
        return lines.joined(separator: "\n")
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
