//
//  AddWorklog.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct AddWorklogCommand: Command {

    struct ParsedArguments {
        let timeSpent: TimeInterval?
        let date: Date?
        let issueID: String?
    }

    let command = "add"

    private(set) var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [DurationParser("TimeSpent")],
                         description: "Add spent time to current issue today.",
                         map: {return ParsedArguments(timeSpent: $0[0].value(), date: nil, issueID: nil)}),

        ArgumentsVariant(arguments: [IssueParser("IssueID"), DurationParser("TimeSpent")],
                         description: "Add worklog to specified issue today.",
                         map: {return ParsedArguments(timeSpent: $0[1].value(), date: nil, issueID: $0[0].value())}),

        ArgumentsVariant(arguments: [DateParser("Date"), IssueParser("IssueID"), DurationParser("TimeSpent")],
                         description: "Add worklog to specified issue at specified date.",
                         map: {return ParsedArguments(timeSpent: $0[2].value(), date: $0[0].value(), issueID: $0[1].value())}),
        ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {

        let parsedArguments: ParsedArguments? = parse(arguments: arguments)

        guard
            let issue = parsedArguments?.issueID ?? context.issue,
            let timeSpent = parsedArguments?.timeSpent
            else {
                context.ui.printError("Time Spent or Issue not specified")
                context.done()
                return
        }

        context.ui.startActivityIndicator()

        addWorklogRequest(forIssue: issue,
                          date: parsedArguments?.date ?? Date(),
                          timeSpent: timeSpent,
                          options: options,
                          context: context)
            .then { result in

                context.ui.stopActivityIndicator()

                switch result {
                case .success(let worklogJSON):
                    let worklog = Worklog(json: worklogJSON)

                    if !options.displayRaw.wasSet {
                        let date = worklog.date?.pretty ?? ""
                        let issue = worklog.issueKey ?? ""
                        let timeSpent = "\(worklog.timeSpent / 3600)h"
                        context.ui.printSuccess("\(date) \(issue): \(timeSpent)")

                    } else {
                        context.ui.printRaw("\(worklogJSON)")
                    }

                case .failure(let error):
                    context.ui.printError("Failed to add worklog", error: error)
                    
                }
                
                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
    }
}
