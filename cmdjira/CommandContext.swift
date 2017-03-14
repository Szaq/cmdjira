//
//  CommandContext.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

private enum CommandContextKey: String {
    case provider
    case project
    case issue

    var key: String {
        return "CommandContextKey_\(self.rawValue)"
    }
}

struct CommandContext {
    var provider: Provider?
    var project: String? {
        didSet {
            issue = nil
        }
    }
    var issue: String?
    var user: User?

    var options: CommandLineOptions
    var ui: UI

    private let onDone: (CommandContext) -> Void
    let disposeBag = DisposeBag()

    static func loadFromUserDefaults(options: CommandLineOptions, onDone: @escaping (CommandContext) -> Void) -> CommandContext {
        let defaults = UserDefaults.standard

        return CommandContext(provider: .jira,
                              project: defaults.string(forKey: CommandContextKey.project.key),
                              issue: defaults.string(forKey: CommandContextKey.issue.key),
                              user: Users().current,
                              options: options,
                              ui: UI(options: options),
                              onDone: onDone)
    }

    func done() {
        onDone(self)
    }

    func saveToUserDefaults() {
        let defautls = UserDefaults.standard
        defautls.set(provider?.rawValue, forKey: CommandContextKey.provider.key)
        defautls.set(project, forKey: CommandContextKey.project.key)
        defautls.set(issue, forKey: CommandContextKey.issue.key)
    }
}
