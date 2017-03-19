//
//  ShowComments.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ShowCommentsCommand: Command {

    let command = "comments"

    var subcommands: [Command] = [AddCommentCommand()]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey")],
                         description: "Show comments from specified issue.",
                         map: {return $0[0].value() as String?}),
        ArgumentsVariant(arguments: [],
                         description: "Show comments from issue queried previously.",
                         map: {_ in return nil as String?}),
        ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {


        guard let issue = parse(arguments: arguments) ?? context.issue else {
            context.ui.printError("Issue not specified")
            context.done()
            return
        }

        context.ui.startActivityIndicator()

        handlePagedResult(context: context,
                          onLoad: { getCommentsRequest(issueID: issue, options: options, context: context, page: $0) },
                          onPage: { self.processPageOfComments(comments: $0, context: context) },
                          onDone: { context.done() },
                          onError: { context.ui.printError("Failed to list comments.", error: $0) })

    }

    func processPageOfComments(comments: [Comment], context: CommandContext) {

        context.ui.stopActivityIndicator()

        if !context.options.displayRaw.wasSet {
            let commentsTable = comments.map {[$0.updated?.pretty.bold.color(.darkGray) ?? "--",
                                               $0.author.bold.color(.blue),
                                               $0.body]}
            context.ui.printTable(rows: commentsTable)
        } else {
            comments.forEach { context.ui.printRaw("\($0.json)") }
        }
    }
}
