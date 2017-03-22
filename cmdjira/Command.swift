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

    func helpStrings(forParentCommand: String) -> [[String]]
    func execute(arguments: [String], context: CommandContext)
}

extension Command {
    var options: Set<CommandLineOption> {return []}
    var subcommands: [Command] {return []}
    var argumentVariants: [ArgumentsVariantType] { return []}

    func helpStrings(forParentCommand parentCommand: String) -> [[String]] {
        let fullCommand = "\(parentCommand) \(command)"

        return [argumentVariants.map {[fullCommand] + $0.descriptions()},
                subcommands.flatMap { $0.helpStrings(forParentCommand: fullCommand) }]
            .flatMap {$0}
    }

    ///Calls this command or one of subcommands
    func call(forArguments arguments: [String],
              context: CommandContext,
              parentCommands: [Command] = []) {

        if
            let subcommand = arguments.first,
            let index = subcommands.index(where: {$0.command == subcommand}) {

            let subarguments = Array(arguments.dropFirst())
            subcommands[index].call(forArguments: subarguments,
                                    context: context,
                                    parentCommands: parentCommands + [self])

        } else {
            guard !context.options.help.wasSet else {
                context.ui.printInformation("Usage:")
                let parentCommandString = parentCommands
                    .map {$0.command}
                .joined(separator: " ")

                printUsage(parentCommand: parentCommandString, context: context)
                context.done()
                return
            }
            execute(arguments: arguments, context: context)
        }
    }

    func printUsage(parentCommand: String, context: CommandContext) {
        context.ui.printTable(rows: helpStrings(forParentCommand: parentCommand),
                              flexibleCols: [2])
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
        let result = subcommand.subcommand(forArguments: subarguments) ?? subcommand
        return result
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
