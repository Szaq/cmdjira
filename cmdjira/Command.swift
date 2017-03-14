//
//  Command.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

protocol Command {
    var options: Set<CommandLineOption> {get}
    var subcommands: [Command] {get}
    var command: String {get}
    var argumentVariants: [ArgumentsVariantType] {get}

    func helpString(forParentCommand: String) -> String
    func execute(arguments: [String], options: CommandLineOptions, context: CommandContext)
}

extension Command {
    var options: Set<CommandLineOption> {return []}
    var subcommands: [Command] {return []}
    var argumentVariants: [ArgumentsVariantType] { return []}

    func helpString(forParentCommand parentCommand: String) -> String {
        let fullCommand = "\(parentCommand) \(command)"
        return argumentVariants
            .map {$0.description(forCommand: fullCommand)}
            .joined(separator: "\n")
    }

    ///Calls this command or one of subcommands
    func call(forArguments arguments: [String],
              options: CommandLineOptions,
              context: CommandContext,
              parentCommands: [Command] = []) {

        if
            let subcommand = arguments.first,
            let index = subcommands.index(where: {$0.command == subcommand}) {

            let subarguments = Array(arguments.dropFirst())
            subcommands[index].call(forArguments: subarguments,
                                    options: options,
                                    context: context,
                                    parentCommands: parentCommands + [self])

        } else {
            guard !options.help.wasSet else {
                context.ui.printInformation("Usage:")
                let parentCommandString = parentCommands
                    .map {$0.command}
                .joined(separator: " ")

                printUsage(parentCommand: parentCommandString, context: context)
                context.done()
                return
            }
            execute(arguments: arguments, options: options, context: context)
        }
    }

    func printUsage(parentCommand: String, context: CommandContext) {
        context.ui.printInformation(helpString(forParentCommand: parentCommand))
        subcommands.forEach { subcommand in
            subcommand.printUsage(parentCommand: "\(parentCommand) \(command)", context: context)
        }
    }

    func completions(forArgumentIndex argumentIndex: Int, inArguments arguments: [String]) -> [String] {
        return subcommands.map {$0.command}
            + argumentVariants.flatMap {
                $0.completions(forArgumentIndex: argumentIndex - 1, inArguments: arguments)
        }
    }

    func subcommand(forCommand command: String) -> Command? {
        guard let index = subcommands.index(where: { $0.command == command }) else {
            return nil
        }

        return subcommands[index]
    }

    func subcommand(forArguments arguments: [String]) -> Command? {
        guard let subcommand = arguments.first.flatMap({subcommand(forCommand: $0)}) else {
            return nil
        }

        let subarguments = Array(cli.unparsedArguments.dropFirst())
        return subcommand.subcommand(forArguments: subarguments)
    }

    func completionsFromSubtree(forArgumentIndex argumentIndex: Int, inArguments arguments: [String]) -> [String] {

        if let subcommand = arguments.first.flatMap({subcommand(forCommand: $0)}) {
            let subarguments = Array(cli.unparsedArguments.dropFirst())
            return subcommand.completionsFromSubtree(forArgumentIndex: argumentIndex - 1, inArguments: subarguments)
        } else {
            return completions(forArgumentIndex: argumentIndex, inArguments: arguments)
        }
    }

    func parse<ParsedArgumentsType>(arguments: [String]) -> ParsedArgumentsType? {
        for variant in argumentVariants {
            if let parsedArguments = variant.parse(arguments) as? ParsedArgumentsType {
                return parsedArguments
            }
        }
        return nil
    }
}
