//
//  CommentsRequests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

func getCommentsRequest(issueID: String, context: CommandContext, page: Page = Page.default) -> Promise<Result<ResultsPage<Comment>>> {
    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/api/2/issue/\(issueID)/comment?startAt=\(page.startAt)&maxResults=\(page.maxResults)"), context: context),
                                 options: context.options)
            .then { result in
                switch result {
                case .failure(let error):
                    return .failure(error)

                case .success(let json):
                    return .success(ResultsPage(json: json, resultsFieldName: "comments"))
                }
        }
    } catch {
        let promise = Promise<Result<ResultsPage<Comment>>>()
        promise.callAsync(.failure(error))
        return promise
    }
}

func addCommentRequest(issue: String, text: String, context: CommandContext) -> Promise<Result<JSON>> {

    let json: JSON = [
        "body" : text
    ]

    do {
        let req = try postRequest(forURL: urlFor(path: "/api/2/issue/\(issue)/comment"),
                                  json: json,
                                  context: context)
        return defaultHTTPGetter(request: req, options: context.options)
    } catch {

        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}
