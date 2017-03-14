//
//  DateCompletionProvider.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

struct DateCompletionProvider: ArgumentCompletionProvider {
    func completions() -> [String] {
        return ["today", "yesterday"]
    }
}
