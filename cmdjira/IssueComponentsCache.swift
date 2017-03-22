//
//  IssueComponentsCache.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private let userDefaultsKey = "cmdjira.IssueComponentsCache"

struct IssueComponentsCache: ArgumentCompletionProvider {
    private let components: [String]
    init() {
        components = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []
    }

    init(components: [String]) {
        self.components = components
    }

    func save() {
        UserDefaults.standard.set(components, forKey: userDefaultsKey)
    }

    func completions() -> [String] {
        return components.map {$0.replacingOccurrences(of: " ", with: "")}
    }
}
