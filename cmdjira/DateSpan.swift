//
//  DateSpan.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct DateSpan {
    let from: Date
    let to: Date

    static var today: DateSpan { return DateSpan(from: Date(), to: Date())}

    static var yesterday: DateSpan {
        let date = Date().addingTimeInterval(-3600 * 24)
        return DateSpan(from: date, to: date)
    }

    static var thisWeek: DateSpan {
        let start = Date().startOfWeak
        return DateSpan(from: start, to: start.weekLater)
    }

    static var previousWeek: DateSpan {
        let start = Date().startOfWeak.weekEarlier
        return DateSpan(from: start, to: start.weekLater)
    }

    static func parse(commandLineArgs: [String]) -> DateSpan? {
        switch commandLineArgs.first {
        case "today"?:
            return DateSpan.today

        case "yesterday"?:
            return DateSpan.yesterday

        case "previous-week"?:
            return DateSpan.previousWeek

        case "current-week"?, nil:
            return DateSpan.thisWeek

        default:

            guard
                let startDate = (commandLineArgs.count >= 1) ? Date.parse(string: commandLineArgs[0]) : nil,
                let endDate = (commandLineArgs.count == 2) ? Date.parse(string: commandLineArgs[1]) : startDate
                else {
                    return nil
            }
            return DateSpan(from: startDate, to: endDate)
        }
    }
}
