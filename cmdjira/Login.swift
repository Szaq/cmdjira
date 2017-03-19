//
//  Login.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct LoginCommand: Command {

    struct ParsedArguments {
        let username: String?
        let password: String?
        let baseURL: String?
    }

    let command = "login"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [StringParser("Username"), StringParser("Password"), StringParser("BaseURL")],
            description: "Add user credentials to keychain.",
            map: {return ParsedArguments(username: $0[0].value(), password: $0[1].value(), baseURL: $0[2].value())})
    ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {


        guard
            let parsedArguments = parse(arguments: arguments) as ParsedArguments?,
            let username = parsedArguments.username,
            let password = parsedArguments.password,
            let baseURL = parsedArguments.baseURL
        else {
            context.ui.printError("Username, password and baseURL not provided")
            context.done()
            return
        }


        var currentContext = context
        currentContext.user = User(username: username, password: password, baseURL: baseURL)

        context.ui.startActivityIndicator()

        getMyselfRequest(options: options, context: currentContext)
            .then { result -> Void in

                context.ui.stopActivityIndicator()

                guard
                    let myself = result.value,
                    let name = myself["name"].string
                    else {
                        context.ui.printError("Failed to login.", error: result.error)
                        currentContext.done()
                        return
                }

                var users = Users()
                users.update(user: User(username: username, password: password, baseURL: baseURL, name: name))
                users.currentUsername = username

                do {
                    try users.saveToKeychain()
                    context.ui.printSuccess()
                    currentContext.done()
                    return
                } catch {
                    context.ui.printError("Failed to save user.", error :error)
                    currentContext.done()
                    return
                }
                
            }
            .addTo(disposeBag: currentContext.disposeBag)
    }
}
