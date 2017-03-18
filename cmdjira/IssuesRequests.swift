//
//  IssuesRequests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

func searchIssues(query: String,
                  options: CommandLineOptions,
                  context: CommandContext,
                  page: Page = Page.default) -> Promise<Result<ResultsPage<Issue>>> {
    do {
        let req = try request(forURL: urlFor(path: "/api/2/search?startAt=\(page.startAt)&maxResults=\(page.maxResults)&jql=\(query)"), context: context)

        return defaultHTTPGetter(request: req,
                                 options: options)
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

func getIssues(forProject projectID: String, options: CommandLineOptions, context: CommandContext, page: Page = Page.default) -> Promise<Result<ResultsPage<Issue>>> {
    return searchIssues(query: "project=\(projectID)", options: options, context: context, page: page)
}

func getIssueRequest(issueID: String, options: CommandLineOptions, context: CommandContext) -> Promise<Result<JSON>> {
    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/api/2/issue/\(issueID)"), context: context),
                                 options: options)
    } catch {
        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}
