//
//  Date+StringInitialization.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

extension Date {
    init?(fromJSONString jsonString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = formatter.date(from: jsonString)  {
            self = date
        } else {
            formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'.'SSSSSZ"
            guard let date = formatter.date(from: jsonString)  else { return nil}
            self = date
        }
    }

    init?(fromJSONStringWithoutTimeZone jsonString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'.'SSSS"
        guard let date = formatter.date(from: jsonString) else { return nil}

        self = date
    }

    init?(fromSimpleString string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        guard let date = formatter.date(from: string) else { return nil}

        self = date
    }
}
