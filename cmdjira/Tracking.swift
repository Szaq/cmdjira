//
//  Tracking.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private let trackingUserDefaultsKey = "cmdjira.tracking"


enum TrackingStatus: String {
    case idle
    case tracking
}

struct Tracking {
    let status: TrackingStatus
    let date: Date
    let issueKey: String?
    ///Amount of time added or removed from tracking
    var timeChange: TimeInterval = 0.0

    init(status: TrackingStatus, issueKey: String? = nil) {
        self.status = status
        self.date = Date()
        self.issueKey = issueKey
    }

    init() {
        if
            let json = UserDefaults.standard.data(forKey: trackingUserDefaultsKey).map({JSON($0)}),
            let status = json["status"].string.flatMap({TrackingStatus(rawValue: $0)}),
            let date = json["date"].double.map({Date(timeIntervalSince1970: $0)}),
            let timeChange = json["timeChange"].double {
            
            self.status = status
            self.date = date
            self.issueKey = json["issue"].string
            self.timeChange = timeChange

        } else {
            self.status = .idle
            self.date = Date()
            self.issueKey = nil
            self.timeChange = 0.0
        }
    }

    func save() {
        UserDefaults.standard.set(try! toJSON().rawData(), forKey: trackingUserDefaultsKey)
    }

    func toJSON() -> JSON {
        if let issueKey = issueKey {
            return [
                "status": status.rawValue,
                "date": date.timeIntervalSince1970,
                "issue": issueKey,
                "timeChange": timeChange
            ]
        } else {
            return [
                "status": status.rawValue,
                "date": date.timeIntervalSince1970
            ]
        }
    }


}
