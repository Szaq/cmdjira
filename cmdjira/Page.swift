//
//  Page.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 16/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation


struct Page {
    let startAt: Int
    let maxResults: Int

    static var `default`: Page { return Page(startAt: 0, maxResults: 50)}

    func next() -> Page {
        return Page(startAt: startAt + maxResults, maxResults: maxResults)
    }
}
