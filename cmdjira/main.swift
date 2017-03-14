//
//  main.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 11/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation



let cli = setupCommandLine()

let executer = CommandExecuter(commands: [
    VersionCommand(),
    ListIssuesCommand(),
    ShowIssueCommand(),
    ShowCommentsCommand(),
    ListWorklogsCommand(),
    ListProjectsCommand(),
    MyselfCommand(),
    ListUsersCommand(),
    ShowTrackingStatusCommand()
    ], options: commandLineOptions)
executer.execute(cli: cli)

dispatchMain()
