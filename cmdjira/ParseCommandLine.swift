//
//  ParseCommandLine.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

enum CommandLineOption {
    case projectID
    case issueID
    case displayRaw
    case user
    case hideSummary
    case help
    case showErrorDetails
    case cancel
    case formatPrompt
    case showBashPrompt
    case showZshPrompt
    case multiline
    case component
    case assignee
    case status

    static var all: [CommandLineOption] = [
        projectID,
        issueID,
        displayRaw,
        user,
        hideSummary,
        help,
        showErrorDetails,
        cancel,
        formatPrompt,
        showBashPrompt,
        showZshPrompt,
        multiline,
        component,
        assignee,
        status
    ]
}

struct CommandLineOptions {
    let projectID = StringOption(shortFlag: "p", longFlag: "project", required: false, helpMessage: "Project ID")
    let issueID = StringOption(shortFlag: "i", longFlag: "issue", required: false, helpMessage: "Issue ID")
    let displayRaw = BoolOption(shortFlag: "r", longFlag: "raw", required: false, helpMessage: "Display result as raw json")
    let user = StringOption(shortFlag: "u", longFlag: "user", required: false, helpMessage: "User used to perform action")
    let hideSummary = BoolOption(longFlag: "hide-summary", required: false, helpMessage: "Hide summary row")
    let help = BoolOption(shortFlag: "h", longFlag: "help", required: false, helpMessage: "Show help")
    let cancel = BoolOption(longFlag: "cancel", required: false, helpMessage: "Cancel uploading worklog")
    let showErrorDetails = BoolOption(longFlag: "show-error-details", required: false, helpMessage: "Show error details")
    let formatPrompt = BoolOption(longFlag: "format-prompt", required: false, helpMessage: "Format tracking data as suitable to display as prompt. See --show-bash-prompt-setter and --show-zsh-prompt-setter")
    let showBashPrompt = BoolOption(longFlag: "show-bash-prompt-setter", required: false, helpMessage: "Show code that needs to be added to ~/.bash_profile in order to display tracking info in BASH promp.")
    let showZshPrompt = BoolOption(longFlag: "show-zsh-prompt-setter", required: false, helpMessage: "Show code that needs to be added to ~/.zshrc in order to display tracking info in ZSH prompt.")
    let multiline = BoolOption(longFlag: "multiline", required: false, helpMessage: "Text input expects multiple lines followed by line containing single word END.")
    let disableSpinner = BoolOption(longFlag: "disable-activity-spinner", required: false, helpMessage: "Disable activity spinner.")
    let component = StringOption(longFlag: "component", required: false, helpMessage: "Only search for components of specified type.")
    let assignee = StringOption(longFlag: "assignee", required: false, helpMessage: "Only search for issues assigned to someone.")
    let status = StringOption(longFlag: "status", required: false, helpMessage: "Only search for issues with specified status")


    func option(_ option: CommandLineOption) -> Option {
        switch option {
        case .projectID: return projectID
        case .issueID: return issueID
        case .displayRaw: return displayRaw
        case .user: return user
        case .hideSummary: return hideSummary
        case .showErrorDetails: return showErrorDetails
        case .help: return help
        case .cancel: return cancel
        case .formatPrompt: return formatPrompt
        case .showBashPrompt: return showBashPrompt
        case .showZshPrompt: return showZshPrompt
        case .multiline: return multiline
        case .component: return component
        case .assignee: return assignee
        case .status: return status
        }
    }

    var all: [Option] {
        return [projectID,
                issueID,
                displayRaw,
                user,
                hideSummary,
                help,
                cancel,
                showErrorDetails,
                formatPrompt,
                showBashPrompt,
                showZshPrompt,
                multiline,
                disableSpinner,
                component,
                assignee,
                status]
    }
}

let commandLineOptions = CommandLineOptions()

func setupCommandLine() -> CommandLine {

    let cli = CommandLine()
    cli.addOptions(commandLineOptions.all)
    return cli
}


func updateCommandContextFromCommandLine(commandContext: inout CommandContext) {
    if let value = commandLineOptions.projectID.value, commandLineOptions.projectID.wasSet {
        commandContext.project = value
    }

    if let value = commandLineOptions.issueID.value, commandLineOptions.issueID.wasSet {
        commandContext.issue = value
    }

    if let value = commandLineOptions.user.value, commandLineOptions.user.wasSet {
        var users = Users()
        if users.select(username: value) {
            let _ = try? users.saveToKeychain()
            commandContext.user = users.current
        } else {
            commandContext.ui.printError("User \(value) not found.")
            exit(-1)
        }
    }
}
