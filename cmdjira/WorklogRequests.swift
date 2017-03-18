//
//  WorklogRequests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

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

