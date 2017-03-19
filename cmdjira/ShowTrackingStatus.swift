//
//  ShowTrackingStatus.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct ShowTrackingStatusCommand: Command {
    let command = "tracking"
    private(set) var subcommands:[Command] = [StartTrackingCommand(), StopTrackingCommand(), ChangeTrackingTime()]
    var options: Set<CommandLineOption> = [.formatPrompt, .showBashPrompt, .showZshPrompt]

    var argumentVariants: [ArgumentsVariantType] = [
        ArgumentsVariant(arguments: [],
                         description: "Show tracking status.",
                         map: {_ in ()}),
        ]

    func execute(arguments: [String], context: CommandContext) {

        if context.options.showBashPrompt.wasSet {
            context.ui.printInformation("To show tracking info in BASH promp. Add this code to ~/.bash_profile:")
            context.ui.printInformation("export PROMPT_COMMAND=\"export PS1='$(cmdjira tracking --format-prompt) >'\"")
            context.done()
            return
        } else if context.options.showZshPrompt.wasSet {
            context.ui.printInformation("To show tracking info in ZSH promp. Add this code to ~/.zshrc:")
            context.ui.printInformation("[ ${ZSH_VERSION} ] && precmd() { myprompt; }\n" +
                "# 'BASH_VERSION' only defined in Bash\n" +
                "# 'PROMPT_COMMAND' is a special environment variable name known to Bash\n" +
                "[ ${BASH_VERSION} ] && PROMPT_COMMAND=myprompt\n" +
                "# function called every time shell is about to draw prompt\n" +
                "myprompt() {\n" +
                "if [ ${ZSH_VERSION} ]; then\n" +
                "# Zsh prompt expansion syntax\n" +
                "PS1='$(cmdjira tracking --format-prompt) ${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'\n" +
                "elif [ ${BASH_VERSION} ]; then\n" +
                "# Bash prompt expansion syntax\n" +
                "PS1='$(cmdjira tracking --format-prompt) ${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'\n" +
                "fi\n" +
                "}")
            context.done()
            return
        }


        let tracking = Tracking()

        switch tracking.status {
        case .idle:
            if !context.options.formatPrompt.wasSet {
                context.ui.printInformation("Not tracking")
            }

        case .tracking:
            let trackedSeconds = (Date().timeIntervalSince1970 - tracking.date.timeIntervalSince1970).prettyString
            let issueKey = tracking.issueKey ?? ""
            let trackingChangeSign = tracking.timeChange > 0 ? "+" : ""
            let timeChange = tracking.timeChange != 0 ? " (\(trackingChangeSign)\(tracking.timeChange.prettyString))".color(.darkGray) : ""

            if context.options.formatPrompt.wasSet {
                context.ui.printInformation("⏱ \(issueKey.color(.darkGray)) \(trackedSeconds.color(.green))\(timeChange)" + "".color(.black))
            } else {
                context.ui.printInformation("⏱ \(issueKey) since \(tracking.date.pretty). Currently: \(trackedSeconds)\(timeChange)")
            }
        }
        
        context.done()
    }
}
