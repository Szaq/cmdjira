//
//  CommandExecuter.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 14/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

class CommandExecuter {
    let commands: [String: Command]
    let options: CommandLineOptions
    let globalOptions: Set<CommandLineOption> = [.displayRaw, .help, .user, .projectID, .issueID, .showErrorDetails, .hideSummary]

    init(commands: [Command], options: CommandLineOptions) {

        self.options = options
        self.commands = [:]
        commands.forEach { command in
            self.commands[command.command] = command
        }
    }

    func execute(cli: CommandLine) {
        do {
            try cli.parse()
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }

        if cli.unparsedArguments.first == "complete" {
            showCompletion()
            exit(0)
        }


        var commandContext = CommandContext.loadFromUserDefaults(options: options,
                                                                 onDone: {
                $0.saveToUserDefaults()
                exit(0)
        })
        
        updateCommandContextFromCommandLine(commandContext: &commandContext)

        guard
            let commandText = cli.unparsedArguments.first,
            let command = commands[commandText]
            else {
                commandContext.ui.printInformation("cmdjira version \(version)")
                let commandsList = commands.keys.joined(separator: ", ")
                commandContext.ui.printInformation("Valid commands: \(commandsList)")
                cli.printUsage()
                commandContext.ui.printInformation("Add 'complete -C \"cmdjira complete\" cmdjira' to your ~/.bash_profile or  ~/.zshrc to get automcompletion")
                exit(EX_USAGE)
        }

        let subarguments = Array(cli.unparsedArguments.dropFirst())
        //Subarguments accept wrong number of arguments
        command.call(forArguments: subarguments, context: commandContext)
    }

    private func showCompletion() {
        guard
            let commandLine = ProcessInfo.processInfo.environment["COMP_LINE"],
            let wordIndex = ProcessInfo.processInfo.environment["COMP_CWORD"].flatMap({Int($0)})
            //let point = ProcessInfo.processInfo.environment["COMP_POINT"].flatMap({Int($0)})
            else { return }

        let words = commandLine.split(by: " ")
        let cli = CommandLine(arguments: words)
        try? cli.parse()


        let wordAtPoint = wordIndex < words.count ? words[wordIndex] : "INVALID"

        if wordAtPoint.hasPrefix("-") {
            let availableOptions: [Option] = self.availableOptions(forArguments: cli.unparsedArguments)

            return availableOptions.forEach {
                if let longFlag = $0.longFlag {
                    print("--\(longFlag)")
                }

                if let shortFlag = $0.shortFlag {
                    print("-\(shortFlag)")
                }
            }
            return
        }

        let wordAtPreviousPoint = ((wordIndex - 1) < words.count && (wordIndex - 1) >= 0) ? words[wordIndex - 1] : "INVALID"

        let availableOptions: [CommandLineOption] = self.availableOptions(forArguments: cli.unparsedArguments)

        if let indexOfOption = availableOptions.index(where: {
            let option = options.option($0)

            let isLongOptionSame = option.longFlag.map { "--\($0)" == wordAtPreviousPoint } ?? false
            let isShortOptionSame = option.shortFlag.map { "-\($0)" == wordAtPreviousPoint } ?? false

            return isLongOptionSame || isShortOptionSame
        }),
            let parser = options.parser(availableOptions[indexOfOption]) {
            parser.completions.forEach {print($0)}
        }
        
        if let currentCommand = cli.unparsedArguments.first.flatMap({commands[$0]}) {
            let subarguments = Array(cli.unparsedArguments.dropFirst())
            currentCommand
                .completionsFromSubtree(forArgumentIndex: wordIndex - 1, inArguments: subarguments)
                .forEach {print($0)}
        } else {
            commands.keys.forEach {print($0)}
        }
    }

    private func availableOptions(forArguments arguments: [String]) -> [CommandLineOption] {
        return Array(globalOptions.union(subcommand(forArguments: arguments)?.options ?? []))
    }

    private func availableOptions(forArguments arguments: [String]) -> [Option] {
        return availableOptions(forArguments: arguments).map {options.option($0)}
    }


    private func subcommand(forArguments arguments: [String]) -> Command? {
        guard let commandName = arguments.first else { return nil}

        let command = commands[commandName]

        return command?.subcommand(forArguments: Array(arguments.dropFirst())) ?? command
    }
}
