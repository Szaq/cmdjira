//
//  ListIssues.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ListIssuesCommand: Command {

    let command = "issues"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [ProjectParser("ProjectKey")],
                         description: "List issues in specfied project.",
                         map: {return $0[0].value() as String?}),
        ArgumentsVariant(arguments: [],
                         description: "List issues in project queried previously.",
                         map: {_ in return nil as String?}),
        ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {

        guard let project = parse(arguments: arguments) ?? context.project else {
            context.ui.printError("Project not specified")
            context.done()
            return
        }

        handlePagedResult(
            context: context,
            onLoad: { getIssues(forProject: project, options: options, context: context, page: $0)},
            onPage: { self.processPageOfIssues(issues: $0, context: context)},
            onDone: { context.done() },
            onError: { error in
                context.ui.printError("Failed to get list of project issues.", error: error)
                context.done()
        })
    }

    func processPageOfIssues(issues: [Issue], context: CommandContext) {

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
