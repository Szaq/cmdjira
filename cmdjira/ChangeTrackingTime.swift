//
//  ChangeTrackingTime.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 17/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ChangeTrackingTime: Command {
    let command = "change"

    private(set) var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [DurationParser("Duration")],
                         description: "Add or remove time from current tracking session.",
                         map: { return $0[0].value() as TimeInterval? }),
        ]
    func execute(arguments: [String], context: CommandContext) {


        guard let timeChange = parse(arguments: arguments) as TimeInterval? else {
            context.ui.printError("Duration not specified")
            context.done()
            return
        }

        var tracking = Tracking()

        switch tracking.status {
        case .idle:
            context.ui.printError("Not tracking")
            context.done()

        case .tracking:
            tracking.timeChange += timeChange
            tracking.save()
            context.ui.printSuccess()
        }
        
        context.done()
    }
}
