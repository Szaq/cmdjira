//
//  SearchIssuesCommand.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 19/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation


struct SearchIssuesCommand: Command {

    let command = "search"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "Search issues in JIRA by providing input query interactively or by STDIN.",
                         map: {_ in return nil as String?}),
        ]

    func execute(arguments: [String], context: CommandContext) {

        let query = context.ui.prompt(label: "Search query:", multiline: context.options.multiline.wasSet)

        context.ui.startActivityIndicator()

        handlePagedResult(
            context: context,
            onLoad: { searchIssues(query: query, context: context, page: $0)},
            onPage: { self.processPageOfIssues(issues: $0, context: context)},
            onDone: { context.done() },
            onError: { error in
                context.ui.printError("Failed to get list of project issues.", error: error)
                context.done()
        })
    }

    func processPageOfIssues(issues: [Issue], context: CommandContext) {

        context.ui.stopActivityIndicator()

        IssuesCache(issues:  issues.map{$0.key}).save()

        if !context.options.displayRaw.wasSet {
            let issuesTable = issues.map {[$0.key, $0.status, $0.assignee.map {" [\($0)]"} ?? "", $0.summary]}
            context.ui.printTable(rows: issuesTable)

        } else {
            issues.forEach { issue in
                context.ui.printRaw("\(issue.json)")
            }
        }
    }
}
