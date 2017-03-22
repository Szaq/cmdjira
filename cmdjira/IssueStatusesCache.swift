//
//  IssueStatusesCache.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private let userDefaultsKey = "cmdjira.IssueStatusesCache"

struct IssueStatusesCache: ArgumentCompletionProvider {
    private let statuses: [String]
    init() {
        statuses = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []
    }

    init(statuses: [String]) {
        self.statuses = statuses
    }

    func save() {
        UserDefaults.standard.set(statuses, forKey: userDefaultsKey)
    }

    func completions() -> [String] {
        return statuses.map {$0.replacingOccurrences(of: " ", with: "")}
    }
}
