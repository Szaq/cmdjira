//
//  CmdJIRAErrors.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 11/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

enum CmdJIRAErrors: Error {
    case unknown(String)
    case unknownHTTPError(Int, String)
    case unauthorized(String)
}
