//
//  TimeInterval+Print.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 17/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension TimeInterval {
    var prettyString: String {
        let trackedHours = Int(self) / 3600
        let trackedMinutes = (Int(self) - trackedHours * 3600) / 60

        let hoursString = trackedHours > 0 ? "\(trackedHours)h" : ""
        let minutesString = trackedMinutes > 0 ? "\(trackedMinutes)m" :""
        guard trackedHours > 0 || trackedMinutes > 0 else {
            return "0m"
        }
        return [hoursString, minutesString].joined(separator: " ")
    }
}
