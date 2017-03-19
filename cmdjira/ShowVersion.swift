//
//  ShowVersion
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct VersionCommand: Command {

    let command = "version"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "Displays application version.",
                         map: {_ in ()}),
        ]


    func execute(arguments: [String], context: CommandContext) {
        print ("Version \(version)")
        context.done()
    }
}
