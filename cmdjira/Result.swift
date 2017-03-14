//
//  Result.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 11/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

enum Result<TYPE> {
    case success(TYPE)
    case failure(Error)
}

extension Result {
    var value: TYPE? {
        switch self {
        case .success(let value): return value
        default:
            return nil
        }
    }

    var error: Error? {
        switch self {
        case .failure(let error): return error
        default:
            return nil
        }
    }
}
