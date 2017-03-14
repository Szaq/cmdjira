//
//  Logout.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct LogoutCommand: Command {

    let command = "logout"
    
    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [UsernameParser("Username")],
                         description: "Remove user from keychain.",
                         map: {return $0[0].value() as String?})
    ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {

        guard let username = parse(arguments: arguments) as String? else {
            context.ui.printError("Username not provided")
            context.done()
            return
        }

        var users = Users()
        users.remove(forUsername: username)

        do {
            try users.saveToKeychain()
            context.ui.printSuccess()
        } catch {
            context.ui.printError("Failed to remove user", error: error)
        }
        
        context.done()
    }
}
