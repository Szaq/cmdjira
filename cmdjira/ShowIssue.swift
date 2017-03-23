//
//  ShowIssue.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ShowIssueCommand: Command {

    let command = "issue"

    var subcommands: [Command] = [AssignIssueCommand(), SetIssueStatusCommand()]
    
    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey")],
            description: "Show details of specfied issue.",
            map: {return $0[0].value() as String?}),
        ArgumentsVariant(arguments: [],
                         description: "Show details of issue queried previously.",
                         map: {_ in return nil as String?}),
    ]

    func execute(arguments: [String], context: CommandContext) {


        guard let issue = parse(arguments: arguments) ?? context.issue else {
            context.ui.printError("Issue not specified")
            context.done()
            return
        }

        context.ui.startActivityIndicator()

        getIssueRequest(issueID: issue, context: context)
            .then { result in

                context.ui.stopActivityIndicator()

                let issue = result.value.map {Issue(json: $0)}

                if let issue = issue, !context.options.displayRaw.wasSet {

                    let rows: [[String]?] = [
                        ["Status", issue.status],
                        issue.assignee.map {["Assignee", $0]},
                        issue.type.map {["Type", $0]},
                        issue.priority.map {["Priority", $0]},
                        issue.duedate.map {["Due date", $0.pretty]},
                        issue.components.flatMap {$0.count > 0 ?["Components", $0.joined(separator: ", ")] : nil},
                        issue.labels.flatMap {$0.count > 0 ? ["Labels", $0.joined(separator: ", ")] : nil},
                        issue.project.map {["Project", "\($0) <\(issue.projectURL ?? String())>"]},
                        issue.timeSpent.map {["Time Spent", TimeInterval($0).prettyString]},
                        issue.updated.map {["Updated", $0.pretty]},
                        issue.reporter.map {["Reporter", $0]},
                        issue.url.map {["URL", $0]},
                        ]


                    context.ui.printInformation("\(issue.key.bold): \(issue.summary)\n")

                    context.ui.printTable(rows: rows.flatMap {$0})
                    context.ui.printInformation("\nDescription:\n".bold)
                    context.ui.printInformation(issue.description)
                    context.ui.printInformation("\nLast Comments:\n".bold)
                    let commentsTable = issue.comments?.map {[$0.updated?.pretty.bold.color(.darkGray) ?? "--",
                                                       $0.author.bold.color(.blue),
                                                       $0.body]} ?? []
                    context.ui.printTable(rows: commentsTable)

                } else {
                    context.ui.printRaw("\(result)")
                }
                
                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
    }
}
