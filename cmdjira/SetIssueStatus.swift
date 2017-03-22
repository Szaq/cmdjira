//
//  SetIssueStatus.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 22/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

func normalize(transitionName: String) -> String {
    return transitionName.lowercased().replacingOccurrences(of: " ", with: "")
}

class SetIssueStatusCommand: Command {
    struct ParsedArguments {
        let issue: String?
        let status: String?
    }

    var command = "set-status"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey"), IssueStatusParser("status")],
                         description: "Update status of issue to specified status.",
                         map: { return ParsedArguments(issue: $0[0].value(), status: $0[1].value()) }),
        ArgumentsVariant(arguments: [IssueStatusParser("status")],
                         description: "Update status of default issue to specified status.",
                         map: { return ParsedArguments(issue: nil, status: $0[1].value()) })
    ]

    func execute(arguments: [String], context: CommandContext) {

        guard
            let parsedArguments = parse(arguments: arguments) as ParsedArguments?,
            let issue = parsedArguments.issue ?? context.issue,
            let status = parsedArguments.status.map({normalize(transitionName: $0)})
            else {
                context.ui.printError("Issue or status not specified")
                context.done()
                return
        }

        getTransitions(issue: issue, context: context)
        .then { result in
            switch result {
            case .success(let json):
                let transitions = json["transitions"].arrayValue.map {Transition(json: $0)}
                IssueStatusesCache(statuses: transitions.map {$0.name}).save()

                if let index = transitions.index(where: { normalize(transitionName: $0.name) == status }) {
                    transition(issue: issue, withTransitionID: transitions[index].id, context: context)
                        .then {result in

                            switch result {
                            case .success(let transitionJSON):
                                if context.options.displayRaw.wasSet {
                                    context.ui.printRaw("\(transitionJSON)")
                                } else {
                                    context.ui.printSuccess()
                                }
                            case .failure(let transitionError):
                                context.ui.printError("Failed to change status of \(issue) to \(status)",
                                    error: transitionError)
                            }
                            context.done()
                    }
                    .addTo(disposeBag: context.disposeBag)
                } else {
                    context.ui.printError("Status not found. Try one from list below (You may omit spaces and input as lowercase):")
                    context.ui.printTable(rows: transitions.map {[$0.name.color(.red)]})
                    context.done()
                }


            case .failure(let error):
                context.ui.printError("Failed to change status of \(issue) to \(status)", error: error)
                context.done()
            }
        }
        .addTo(disposeBag: context.disposeBag)
    }
}
