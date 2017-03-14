//
//  IssuesCache.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private let userDefaultsKey = "cmdjira.IssuesCache"

struct IssuesCache: ArgumentCompletionProvider {
    private let issues: [String]
    init() {
        issues = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []
    }

    init(issues: [String]) {
        self.issues = issues
    }

    func save() {
        UserDefaults.standard.set(issues, forKey: userDefaultsKey)
    }

    func completions() -> [String] {
        return issues
    }
}
