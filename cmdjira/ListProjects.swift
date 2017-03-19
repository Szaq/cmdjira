//
//  ListProjects.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ListProjectsCommand: Command {

    let command = "projects"

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "List Projects available for the user.",
                         map: {_ in ()}),
        ]

    func execute(arguments: [String], options:CommandLineOptions, context: CommandContext) {

        context.ui.startActivityIndicator()

        getProjectsRequest(options: options, context: context)
            .then { result in

                context.ui.stopActivityIndicator()

                switch result {
                case .success(let value):
                    guard
                        let projects = value.array?.map ({ Project(json: $0) })
                        else { break }

                    ProjectsCache(projects: projects.map {$0.key}).save()

                    if !options.displayRaw.wasSet {
                        let projectsTable = projects.map {[$0.key, $0.name]}
                        context.ui.printTable(rows: projectsTable)

                    } else {
                        context.ui.printRaw("\(value)")
                    }

                case .failure(let error):
                    context.ui.printError("Failed to list projects.", error: error)
                }
                
                context.done()
            }
            .addTo(disposeBag: context.disposeBag)
    }
}
