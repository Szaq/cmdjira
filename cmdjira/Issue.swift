//
//  Issue.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct Issue {
    let json: JSON

    var key: String {
        return json["key"].stringValue
    }

    var url: String? {
        return json["self"].string
    }

    var summary: String {
        return json["fields"]["summary"].stringValue
    }

    var description: String {
        return json["fields"]["description"].stringValue
    }

    var status: String {
        return json["fields"]["status"]["name"].stringValue
    }

    var assignee: String? {
        return json["fields"]["assignee"]["name"].stringValue
    }

    var components: [String]? {
        return json["fields"]["components"].array?.flatMap {$0["name"].string}
    }

    var labels: [String]? {
        return json["fields"]["labels"].array?.flatMap {$0["name"].string}
    }

    var type: String? {
        return json["fields"]["issuetype"]["name"].string
    }

    var duedate: Date? {
        return json["fields"]["duedate"].string.flatMap { Date(fromJSONString: $0) }
    }

    var priority: String? {
        return json["fields"]["priority"]["name"].string
    }

    var project: String? {
        return json["fields"]["project"]["key"].string
    }

    var projectURL: String? {
        return json["fields"]["project"]["self"].string
    }

    var timeSpent: Int? {
        return json["fields"]["timespent"].int
    }

    var updated: Date? {
        return json["fields"]["timespent"].string.flatMap { Date(fromJSONString: $0) }
    }

    var reporter: String? {
        return json["fields"]["reporter"]["name"].stringValue
    }

    var comments: [Comment]? {
        return json["fields"]["comment"]["comments"].array?.flatMap {Comment(json: $0)}
    }
}

extension Issue: JSONDecodable {
}
