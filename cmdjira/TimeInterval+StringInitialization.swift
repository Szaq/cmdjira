//
//  TimeInterval+StringInitialization.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension TimeInterval {
    init?(fromCommandLine commandLine: String) {
        if commandLine.hasSuffix("s"),
            let value = TimeInterval(commandLine.substring(to: commandLine.index(before: commandLine.endIndex))) {
            self = value
        } else if commandLine.hasSuffix("m"),
            let value = TimeInterval(commandLine.substring(to: commandLine.index(before: commandLine.endIndex))) {
            self = value * 60
        } else if commandLine.hasSuffix("h"),
            let value = TimeInterval(commandLine.substring(to: commandLine.index(before: commandLine.endIndex))) {
            self = value * 3600
        } else if commandLine.hasSuffix("d"),
            let value = TimeInterval(commandLine.substring(to: commandLine.index(before: commandLine.endIndex))) {
            self = value * 3600 * 24
        } else if commandLine.hasSuffix("w"),
            let value = TimeInterval(commandLine.substring(to: commandLine.index(before: commandLine.endIndex))) {
            self = value * 3600 * 24 * 7
        } else if let value = TimeInterval(commandLine) {
            self = value
        } else {
            let values = commandLine.split(by: ":")
            if values.count == 2,
                let hours = Int(values[0]),
                let minutes = Int(values[1]),
                hours <= 24, minutes <= 60 {

                self = TimeInterval(hours * 3600 + minutes * 60)

            } else {
                return nil
            }
        }
    }
}
