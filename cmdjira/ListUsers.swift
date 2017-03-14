//
//  ListUsers.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ListUsersCommand: Command {
    let command = "users"
    private(set) var subcommands: [Command] = [LoginCommand(), LogoutCommand(), SelectUserCommand()]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "List users in keychain.",
                         map: {_ in ()}),
        ]


    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {
        let users = Users()
        let usersTable = users.users.map {user in [user.username == users.currentUsername ? "*" : " ",
                                           user.username,
                                           user.name.map {" <\($0)>"} ?? "",
                                           user.baseURL]}
        context.ui.printTable(rows: usersTable)
        context.done()
    }
}
