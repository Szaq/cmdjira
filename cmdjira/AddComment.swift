//
//  AddComment.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct AddCommentCommand: Command {
    struct ParsedArguments {
        let issue: String?
    }


    let command = "add"

    var options: Set<CommandLineOption> = [.multiline]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey")],
                         description: "Add comment to specified issue.",
                         map: {ParsedArguments(issue: $0[0].value())}),

        ArgumentsVariant(arguments: [],
                         description: "Add comment to current issue.",
                         map: {_ in ParsedArguments(issue: nil)})

    ]

    func execute(arguments: [String], context: CommandContext) {
        guard
        let parsedArguments = parse(arguments: arguments) as ParsedArguments?,
        let issue = parsedArguments.issue ?? context.issue
            else {
                context.ui.printError("Issue or text not specified.")
                context.done()
                return
        }

        let text = context.ui.prompt(label: "Comment text:", multiline: context.options.multiline.wasSet)

        context.ui.startActivityIndicator()

        addCommentRequest(issue: issue, text: text, context: context)
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
                    context.ui.printError("Failed",error: error)
                }
                context.done()
        }
        .addTo(disposeBag: context.disposeBag)

    }
}
