//
//  GetMyself.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct MyselfCommand: Command {

    let command = "myself"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "Get information about current account.",
                         map: {_ in ()}),
    ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {

        context.ui.startActivityIndicator()

        getMyselfRequest(options: options, context: context)
            .then { result in

                context.ui.stopActivityIndicator()

                switch result {
                case .success(let myselfJSON):
                    context.ui.printRaw("\(myselfJSON)")

                case .failure(let error):
                    context.ui.printError("Failed to get myself info", error: error)
                }
                
                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
    }
}
