//
//  ListWorklogs.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ListWorklogsCommand: Command {

    let command = "worklogs"

    private(set) var subcommands: [Command] = [AddWorklogCommand()]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "List worklogs for current week.",
                         map: {_ -> DateSpan? in return DateSpan.today}),

        ArgumentsVariant(arguments: [DateParser("StartDate"), DateParser("EndDate")],
                         description: "List worklogs for specified date span.",
                         map: { (values: [ParsedValue]) -> DateSpan? in
                            if
                                let start = values[0].value() as Date?,
                                let end = values[1].value() as Date? {
                                return DateSpan(from: start, to: end)
                            } else {
                                return nil
                            }}),

        ArgumentsVariant(arguments: [DateSpanParser("Date")],
                         description: "List worklogs for specified date.",
                         map: {values -> DateSpan? in return values[0].value()}),
    ]

    func execute(arguments: [String], context: CommandContext) {

        guard let project = context.project else {
            context.ui.printError("Project not specified")
            context.done()
            return
        }

        let dateSpan = parse(arguments: arguments) ?? DateSpan.thisWeek

        context.ui.startActivityIndicator()

        getWorklogRequest(forProject: project, dateSpan: dateSpan, context: context)
            .then { result in

                context.ui.stopActivityIndicator()

                switch result {
                case .success(let worklogsJSON):

                    if !context.options.displayRaw.wasSet {
                        let worklogs = worklogsJSON.arrayValue.map {Worklog(json: $0)}

                        let sum = worklogs.reduce(0.0) {$0 + $1.timeSpent}

                        let worklogsTable = worklogs.map {[$0.date?.pretty ?? "",
                                                           $0.issueKey ?? "",
                                                           "\($0.timeSpent / 3600)h"]}


                        let shouldDisplayFooter = !context.options.hideSummary.wasSet && !context.options.displayRaw.wasSet
                        let footer:[String]? = shouldDisplayFooter ? ["Sum","","\(sum / 3600)"] : nil
                        context.ui.printTable(rows: worklogsTable, header:["Date", "Issue", "Time"], footer: footer)

                    } else {
                        context.ui.printRaw("\(worklogsJSON)")
                    }

                case .failure(let error):
                    context.ui.printError("Failed to list worklogs.", error: error)
                }

                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
    }
}
