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
    
    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey")],
            description: "Show details of specfied issue.",
            map: {return $0[0].value() as String?}),
        ArgumentsVariant(arguments: [],
                         description: "Show details of issue queried previously.",
                         map: {_ in return nil as String?}),
    ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {


        guard let issue = parse(arguments: arguments) ?? context.issue else {
            context.ui.printError("Issue not specified")
            context.done()
            return
        }

        getIssueRequest(issueID: issue, options: options, context: context)
            .then { result in
                let issue = result.value.map {Issue(json: $0)}

                if let issue = issue, !options.displayRaw.wasSet {

                    let assigne = issue.assignee.map {" [\($0)]"} ?? ""
                    print("\(issue.key) \(issue.status)\(assigne): \(issue.summary)")
                } else {
                    context.ui.printRaw("\(result)")
                }
                
                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
    }
}
