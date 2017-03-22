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
    var subcommands: [Command] = [SearchIssuesCommand()]

    var options: Set<CommandLineOption> = [.component, .assignee, .status]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [ProjectParser("ProjectKey")],
                         description: "List issues in specfied project.",
                         map: {return $0[0].value() as String?}),
        ArgumentsVariant(arguments: [],
                         description: "List issues in project queried previously.",
                         map: {_ in return nil as String?}),
        ]

    func execute(arguments: [String], context: CommandContext) {

        guard let project = parse(arguments: arguments) ?? context.project else {
            context.ui.printError("Project not specified")
            context.done()
            return
        }

        context.ui.startActivityIndicator()

        handlePagedResult(
            context: context,
            onLoad: { getIssues(forProject: project, context: context, page: $0)},
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
        let components = issues.flatMap {$0.components}.flatMap {$0}.unique()
        IssueComponentsCache(components: components).save()

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
