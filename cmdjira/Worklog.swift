//
//  Worklog.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct Worklog {
    let json: JSON

    var timeSpent: TimeInterval {
        return TimeInterval(json["timeSpentSeconds"].intValue)
    }

    var issueKey: String? {
        return json["issue"]["key"].string
    }

    var date: Date? {
        return json["dateStarted"].string.flatMap {Date(fromJSONStringWithoutTimeZone: $0)}
    }
}
