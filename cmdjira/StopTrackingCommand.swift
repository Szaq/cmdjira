//
//  StopTrackingCommand.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct StopTrackingCommand: Command {
    let command = "stop"
    var options: Set<CommandLineOption> { return [.cancel]}

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "Stop tracking. Use --cancel to not post worklog.",
                         map: {_ in nil as String?}),
        ]

    func execute(arguments: [String], options: CommandLineOptions, context: CommandContext) {
        let tracking = Tracking()

        switch tracking.status {
        case .idle:
            context.ui.printError("Not tracking")
            context.done()

        case .tracking:
            guard let issueKey = tracking.issueKey else {
                context.ui.printError("Issue was not specified")
                context.done()
                return
            }

            Tracking(status: .idle).save()

            if options.cancel.wasSet {
                context.ui.printSuccess("OK. Canceled upload")
                context.done()
                return
            }

            context.ui.startActivityIndicator()

            let trackedSeconds = (Date().timeIntervalSince1970 - tracking.date.timeIntervalSince1970) + tracking.timeChange
            addWorklogRequest(forIssue: issueKey,
                              date: Date(),
                              timeSpent: trackedSeconds,
                              options: options,
                              context: context)
            .then{ result in

                context.ui.stopActivityIndicator()

                switch result {
                case .success(let value):

                    let worklog = Worklog(json: value)

                    if !options.displayRaw.wasSet {
                        let date = worklog.date?.pretty ?? ""
                        let issue = worklog.issueKey ?? ""
                        let timeSpent = "\(worklog.timeSpent / 3600)h"
                        context.ui.printSuccess("\(date) \(issue): \(timeSpent)")

                    } else {
                        context.ui.printRaw("\(result)")
                    }

                case .failure(let error):
                    context.ui.printError("Failed to add worklog", error: error)
                }
                context.done()
                }
                .addTo(disposeBag: context.disposeBag)
        }
    }
}
