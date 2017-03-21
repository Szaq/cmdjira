//
//  IssuesRequests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

func searchIssues(query: String,
                  context: CommandContext,
                  page: Page = Page.default) -> Promise<Result<ResultsPage<Issue>>> {
    do {
        let req = try request(forURL: urlFor(path: "/api/2/search?startAt=\(page.startAt)&maxResults=\(page.maxResults)&jql=\(query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? query)"), context: context)

        return defaultHTTPGetter(request: req,
                                 options: context.options)
            .then { result in
                switch result {
                case .failure(let error):
                    return .failure(error)

                case .success(let json):
                    return .success(ResultsPage(json: json, resultsFieldName: "issues"))
                }
        }
    } catch {
        let promise = Promise<Result<ResultsPage<Issue>>>()
        promise.callAsync(.failure(error))
        return promise
    }
}

func getIssues(forProject projectID: String, context: CommandContext, page: Page = Page.default) -> Promise<Result<ResultsPage<Issue>>> {
    let componentPart = context.options.component.wasSet ? " AND component=\(context.options.component.value ?? String())" : ""
    let assigneePart = context.options.assignee.wasSet ? " AND assignee=\(context.options.assignee.value ?? String())" : ""
    let statusPart = context.options.status.wasSet ? " AND status=\"\(context.options.status.value ?? String())\"" : ""
    return searchIssues(query: "project=\(projectID)\(componentPart)\(assigneePart)\(statusPart)", context: context, page: page)
}

func getIssueRequest(issueID: String, context: CommandContext) -> Promise<Result<JSON>> {
    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/api/2/issue/\(issueID)"), context: context),
                                 options: context.options)
    } catch {
        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}


func assign(issue: String, toUserWithNick nickOrMe: String, context: CommandContext) -> Promise<Result<JSON>> {

    guard let nick = nickOrMe == "me" ? context.user?.name : nickOrMe else {
        context.ui.printError("User name not specified")
        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(CmdJIRAErrors.unauthorized("User name not specified")))
        return promise
    }

    let json: JSON = ["name" : nick]

    do {
        let req = try putRequest(forURL: urlFor(path: "/api/2/issue/\(issue)/assignee"),
                                  json: json,
                                  context: context)
        return defaultHTTPGetter(request: req, options: context.options)
    } catch {

        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}

