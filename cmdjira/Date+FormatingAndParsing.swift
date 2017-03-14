//
//  Date+FormatingAndParsing.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension Date {
    var startOfWeak: Date {
        let comps = Calendar.current.dateComponents([.weekday], from: self)
        let weekdayToday = comps.weekday ?? 2
        //MON = 2, SUN = 1
        let daysSinceMonday = (weekdayToday > 1) ? (weekdayToday - 2) : 6

        return addingTimeInterval(TimeInterval(-3600 * 24 * daysSinceMonday))
    }

    static var yesterday: Date {
        return Date().addingTimeInterval(-3600 * 24)
    }

    var weekEarlier: Date {
        return self.addingTimeInterval(-3600 * 24 * 7)
    }

    var weekLater: Date {
        return self.addingTimeInterval(3600 * 24 * 7)
    }

    var yyyyMMdd: String {
        let comps = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let month = comps.month! >= 10 ? "\(comps.month!)" : "0\(comps.month!)"
        let day = comps.day! >= 10 ? "\(comps.day!)" : "0\(comps.day!)"
        return "\(comps.year!)-\(month)-\(day)"
    }

    var yyyyMMddhhmmss: String {
        let comps = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: self)
        let month = comps.month! >= 10 ? "\(comps.month!)" : "0\(comps.month!)"
        let day = comps.day! >= 10 ? "\(comps.day!)" : "0\(comps.day!)"
        let hour = comps.hour! >= 10 ? "\(comps.hour!)" : "0\(comps.hour!)"
        let minute = comps.minute! >= 10 ? "\(comps.minute!)" : "0\(comps.minute!)"
        return "\(comps.year!)-\(month)-\(day) \(hour):\(minute)"
    }

    var jsonWithoutTimeZone: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'.'mmmm"
        return formatter.string(from: self)
    }

    var pretty: String {
        let comps = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: self)
        let month = comps.month! >= 10 ? "\(comps.month!)" : "0\(comps.month!)"
        let day = comps.day! >= 10 ? "\(comps.day!)" : "0\(comps.day!)"
        let hour = comps.hour! >= 10 ? "\(comps.hour!)" : "0\(comps.hour!)"
        let minute = comps.minute! >= 10 ? "\(comps.minute!)" : "0\(comps.minute!)"

        if isToday {
            return "\(hour):\(minute)"
        }

        if self > Date().addingTimeInterval(-3600 * 24 * 6) {
            let weekday = Calendar.current.dateComponents([.weekday], from: self).weekday!

            switch weekday {
            case 2: return "MON"
            case 3: return "TUE"
            case 4: return "WED"
            case 5: return "THU"
            case 6: return "FRI"
            case 7: return "SAT"
            case 1: return "SUN"
            default: break
            }
        }

        return "\(comps.year!)-\(month)-\(day) \(hour):\(minute)"
    }

    static func parse(string: String) -> Date? {
        switch string {
            case "today": return Date()
            case "yesterday": return Date.yesterday
        default:
            return Date(fromSimpleString: string)
            ?? Date(fromSimpleString: string)
            ?? Date(fromJSONStringWithoutTimeZone: string)
        }
    }

    var isToday: Bool {
        let comps = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: self)
        let compsToday = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
        return comps.year == compsToday.year && comps.month == compsToday.month && comps.day == compsToday.day
    }
}
