//
//  Comment.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 12/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct Comment {
    let json: JSON

    var author: String {
        return json["author"]["displayName"].stringValue
    }

    var body: String {
        return json["body"].stringValue
    }

    var updated: Date? {
        return json["updated"].string.flatMap {Date(fromJSONString: $0)}
    }
}

extension Comment: JSONDecodable {
}
