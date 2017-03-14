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
        return json["fields"]["assignee"]["displayName"].stringValue
    }
}

extension Issue: JSONDecodable {
}
