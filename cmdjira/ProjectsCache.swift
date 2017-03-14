//
//  ProjectsCache.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private let userDefaultsKey = "cmdjira.ProjectsCache"

struct ProjectsCache: ArgumentCompletionProvider {
    private let projects: [String]
    init() {
        projects = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []
    }

    init(projects: [String]) {
        self.projects = projects
    }

    func save() {
        UserDefaults.standard.set(projects, forKey: userDefaultsKey)
    }

    func completions() -> [String] {
        return projects
    }
}
