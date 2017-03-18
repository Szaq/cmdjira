//
//  ProjectsRequests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

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
