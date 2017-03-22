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

    func printTable(rows: [[String]], header: [String]? = nil, footer: [String]? = nil, flexibleCols: [Int] = []) {

        let verticalSeparator = " "

        var maxColLengths: [Int] = []

        //Add header and footer
        let formatedHeader = header.map {row in [row.map {$0.bold}]} ?? []
        let formatedFooter = footer.map {row in [row.map {$0.bold}]} ?? []
        let rowsWithHeaderAndFooter = formatedHeader + rows + formatedFooter

        //Compute cols width
        for row in rowsWithHeaderAndFooter {
            for (colIndex, col) in row.enumerated() {

                if colIndex >= maxColLengths.count {
                    maxColLengths.append(0)
                }

                let strippedANSICol = col.replacingOccurrences(of: "\u{001B}\\[[0-9,\\;]*m", with: "",
                                                               options: String.CompareOptions.regularExpression,
                                                               range: Range(uncheckedBounds: (col.startIndex, upper: col.endIndex)))

                maxColLengths[colIndex] = max(strippedANSICol.utf8.count, maxColLengths[colIndex])
            }
        }

        //Compensate for too-long flexible column. Pick sensible width if in doubt
        var terminalSize = winsize()
        let _ = ioctl(0, TIOCGWINSZ, &terminalSize)
        let terminalWidth = terminalSize.ws_col > 0 ? terminalSize.ws_col : 999
        let tableWidth = maxColLengths.reduce(0, +)
        let separatorsWidth = verticalSeparator.characters.count * (maxColLengths.count - 1)

        if tableWidth + separatorsWidth > Int(terminalWidth) {
            let flexibleWidth = flexibleCols.reduce(0, {$0 + maxColLengths[$1]})
            let nonFlexibleWidth = tableWidth - flexibleWidth
            let availableSpaceForFlexible = Int(terminalWidth) - nonFlexibleWidth - separatorsWidth
            flexibleCols.forEach {
                maxColLengths[$0] = maxColLengths[$0] * availableSpaceForFlexible / flexibleWidth
            }
        }

        //Split too long columns
        let splittedRows = rowsWithHeaderAndFooter.flatMap {row -> [[String]] in
            let splittedCols = row.enumerated().map { $1.split(atWidth: maxColLengths[$0]) }
            let rowsCount = splittedCols.reduce(0, {max($0, $1.count)})
            return (0 ..< rowsCount).map { rowIndex -> [String] in
                return splittedCols.map {$0.count > rowIndex ? $0[rowIndex] : ""}
            }
        }

        //Draw
        for row in splittedRows {
            for (colIndex, col) in row.enumerated() {
                let strippedANSICol = col.replacingOccurrences(of: "\u{001B}\\[[0-9,\\;]*m", with: "",
                                                               options: String.CompareOptions.regularExpression,
                                                               range: Range(uncheckedBounds: (col.startIndex, upper: col.endIndex)))
                let padWidth = maxColLengths[colIndex] - strippedANSICol.characters.count
                print(col.padded(by: padWidth), terminator: verticalSeparator)
            }
            print("")
        }

    }

}
