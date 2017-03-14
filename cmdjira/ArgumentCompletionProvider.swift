//
//  ArgumentCompletionProvider.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 15/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

protocol ArgumentCompletionProvider {
    func completions() -> [String]
}
