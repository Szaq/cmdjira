//
//  Requests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 11/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

func urlFor(path: String) -> String {
    return path
}

func request(forURL path: String, context: CommandContext) throws -> URLRequest {

    guard let user = context.user else {
        throw CmdJIRAErrors.unauthorized("User not specified")
    }
    
    let url = user.baseURL.hasPrefix("http") ? "\(user.baseURL)/rest\(path)" : "https://\(user.baseURL)/rest\(path)"
    let authStr = "\(user.username):\(user.password)"
    let authData = authStr.data(using: String.Encoding.utf8)!
    let authValue = "Basic \(authData.base64EncodedString())"

    var request = URLRequest(url: URL(string: url)!)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(authValue, forHTTPHeaderField: "Authorization")
    return request
}

func postRequest(forURL url: String, body: Data, context: CommandContext) throws -> URLRequest {
    var req = try request(forURL: url, context: context)
    req.httpMethod = "POST"
    req.httpBody = body
    return req
}

func postRequest(forURL url: String, json: JSON, context: CommandContext) throws -> URLRequest {
    var req = try request(forURL: url, context: context)
    req.httpMethod = "POST"
    req.httpBody = try json.rawData()
    return req
}

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

func getProjectsRequest(options: CommandLineOptions, context: CommandContext) -> Promise<Result<JSON>> {
    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/api/2/project"), context: context),
                                 options: options)
    } catch {
        let promise = Promise<Result<JSON>>()
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

func getCommentsRequest(issueID: String, options: CommandLineOptions, context: CommandContext, page: Page = Page.default) -> Promise<Result<ResultsPage<Comment>>> {
    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/api/2/issue/\(issueID)/comment?startAt=\(page.startAt)&maxResults=\(page.maxResults)"), context: context),
                                 options: options)
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

func getMyselfRequest(options: CommandLineOptions, context: CommandContext) -> Promise<Result<JSON>> {
    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/api/2/myself"), context: context),
                                 options: options)
    } catch {
        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}

func getWorklogRequest(forProject projectID: String, dateSpan: DateSpan, options: CommandLineOptions, context: CommandContext) -> Promise<Result<JSON>> {
    let from = dateSpan.from.yyyyMMdd
    let to = dateSpan.to.yyyyMMdd

    do {
        return defaultHTTPGetter(request: try request(forURL: urlFor(path: "/tempo-timesheets/3/worklogs/?dateFrom=\(from)&dateTo=\(to)"),
                                                      context: context),
                                 options: options)
    } catch {
        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}

func addWorklogRequest(forIssue issue: String, date: Date, timeSpent: TimeInterval, options: CommandLineOptions, context: CommandContext) -> Promise<Result<JSON>> {

    guard let username = context.user?.name else {
        context.ui.printError("User name not specified")
        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(CmdJIRAErrors.unauthorized("User name not specified")))
        return promise
    }

    let json: JSON = [
        "issue" : [ "key" : issue ],
        "author": [ "name" : username ],
        "dateStarted" : date.jsonWithoutTimeZone,
        "timeSpentSeconds": Int(timeSpent)
    ]
    
    do {
        let req = try postRequest(forURL: urlFor(path: "/tempo-timesheets/3/worklogs"),
                                  json: json,
                                  context: context)
        return defaultHTTPGetter(request: req, options: options)
    } catch {

        let promise = Promise<Result<JSON>>()
        promise.callAsync(.failure(error))
        return promise
    }
}

func defaultHTTPGetter(request: URLRequest, options: CommandLineOptions) -> Promise<Result<JSON>> {
    let promise = Promise<Result<JSON>>()

    let task = URLSession.shared.dataTask(with: request) { optionalData, response, error in
        guard
            let httpResponse = response as? HTTPURLResponse,
            let data = optionalData,
            httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            else {
                promise.call(.failure(getErrorFor(response: response, data: optionalData)))
                return
        }

        promise.call(.success(JSON(data)))
    }

    task.resume()
    return promise

}

fileprivate func getErrorFor(response: URLResponse?, data: Data?) -> CmdJIRAErrors {

    guard let httpResponse = response as? HTTPURLResponse else {
        return .unknown("Failed to get http response")
    }

    let dataString = data.flatMap {String(data: $0, encoding: String.Encoding.utf8)} ?? ""
    switch httpResponse.statusCode {
    case 401: return .unauthorized(dataString)
    default: return .unknownHTTPError(httpResponse.statusCode, dataString)
    }
}

