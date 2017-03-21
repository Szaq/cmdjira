//
//  BaseRequests.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 18/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation


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

func putRequest(forURL url: String, body: Data, context: CommandContext) throws -> URLRequest {
    var req = try request(forURL: url, context: context)
    req.httpMethod = "PUT"
    req.httpBody = body
    return req
}

func putRequest(forURL url: String, json: JSON, context: CommandContext) throws -> URLRequest {
    var req = try request(forURL: url, context: context)
    req.httpMethod = "PUT"
    req.httpBody = try json.rawData()
    return req
}
