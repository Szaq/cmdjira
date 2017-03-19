//
//  StartTrackingCommand.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct StartTrackingCommand: Command {
    let command = "start"
    
    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [IssueParser("IssueKey")],
                         description: "Start tracking.",
                         map: {$0[0].value() as String?}),
        ]

    func execute(arguments: [String], context: CommandContext) {


        guard let issue = parse(arguments: arguments) ?? context.issue else {
            context.ui.printError("Issue not specified")
            context.done()
            return
        }

        let tracking = Tracking()

        switch tracking.status {
        case .idle:
            Tracking(status: .tracking, issueKey: issue).save()
            context.ui.printSuccess()

        case .tracking:
            let issueKey = tracking.issueKey ?? ""
            context.ui.printError("Already tracking \(issueKey). Stop before proceeding.")
        }

        context.done()
    }
}
