//
//  SelectUser.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct SelectUserCommand: Command {

    let command = "select"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [UsernameParser("Username")],
                         description: "Select user given by username.",
                         map: {return $0[0].value() as String?})
    ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {

        guard let username = parse(arguments: arguments) as String? else {
            context.ui.printError("Username not provided")
            context.done()
            return
        }

        var users = Users()
        if users.select(username: username) {
            do {
                try users.saveToKeychain()
                context.ui.printSuccess()
            } catch {
                context.ui.printError("Failed to save user.", error: error)
            }
        } else {
            context.ui.printError("User not found")
        }
        context.done()
    }

}
