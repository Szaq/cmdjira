//
//  ANSIColor.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 16/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

enum ANSIColor: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case darkGray = "\u{001B}[0;90m"

    func name() -> String {
        switch self {
        case .black: return "Black"
        case .red: return "Red"
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        case .magenta: return "Magenta"
        case .cyan: return "Cyan"
        case .white: return "White"
        case .darkGray: return "Dark Gray"
        }
    }

    static func all() -> [ANSIColor] {
        return [.black, .red, .green, .yellow, .blue, .magenta, .cyan, .white, .darkGray]
    }
}

extension String {
    func color(_ color: ANSIColor) -> String {
        return color.rawValue + self + ANSIColor.black.rawValue
    }

    var bold: String {
        return"\u{001B}[1m\(self)\u{001B}[0m"
    }
}
