//
//  UserNicksCache.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 21/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private let userDefaultsKey = "cmdjira.UserNicksCache"

struct UserNicksCache: ArgumentCompletionProvider {
    private let nicks: [String]
    init() {
        nicks = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []
    }

    init(nicks: [String]) {
        self.nicks = nicks
    }

    func save() {
        UserDefaults.standard.set(nicks, forKey: userDefaultsKey)
    }

    func completions() -> [String] {
        return nicks
    }
}
