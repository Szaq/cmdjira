//
//  AssignIssue.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 21/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct AssignIssueCommand: Command {
    struct ParsedArguments {
        let issue: String?
        let nick: String?
    }


    let command = "assign"

    var options: Set<CommandLineOption> = [.multiline]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey"), NickParser("Nick")],
                         description: "Assign specified issue to specified user.",
                         map: {ParsedArguments(issue: $0[0].value(), nick: $0[1].value())}),

        ArgumentsVariant(arguments: [NickParser("Nick")],
                         description: "Assign current issue to specified user.",
                         map: {ParsedArguments(issue: nil, nick: $0[0].value())})
    ]

    func execute(arguments: [String], context: CommandContext) {
        guard
            let parsedArguments = parse(arguments: arguments) as ParsedArguments?,
            let issue = parsedArguments.issue ?? context.issue,
            let nick = parsedArguments.nick
            else {
                context.ui.printError("Issue or user not specified.")
                context.done()
                return
        }

        context.ui.startActivityIndicator()

        assign(issue: issue, toUserWithNick: nick, context: context)
            .then { result in

                context.ui.stopActivityIndicator()

                switch result {
                case .success(let json):
                    if context.options.displayRaw.wasSet {
                        context.ui.printRaw("\(json)")
                    } else {
                        context.ui.printSuccess()
                    }

                case .failure(let error):
                    context.ui.printError("Failed to assign issue \(issue)",error: error)
                }
                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
        
    }
}
