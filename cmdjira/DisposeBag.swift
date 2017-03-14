//
//  DisposeBag.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 11/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

class DisposeBag {
    private var objects = [PromiseType]()

    func add(promise: PromiseType) {
        objects.append(promise)
    }
}
