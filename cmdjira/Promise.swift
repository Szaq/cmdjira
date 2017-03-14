//
//  Promise.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 11/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

protocol PromiseType {

}

class Promise<T>: PromiseType {
    private var callback: ((T) -> Void)?

    init() {

    }

    func call(_ value: T) {
        callback?(value)
    }

    func callAsync(_ value: T) {
        DispatchQueue.main.async { [weak self] in
            self?.callback?(value)
        }
    }

    func then<S>(callback: @escaping (T) -> S) -> Promise<S> {
        let promise = Promise<S>()

        self.callback = { promise.call(callback($0)) }

        return promise
    }

    func filter(filter: @escaping (T) -> Bool) -> Promise<T> {
        let promise = Promise<T>()

        callback = {
            if filter($0) {
                promise.call($0)
            }
        }

        return promise
    }

    func addTo(disposeBag: DisposeBag) {
        disposeBag.add(promise: self)
    }
}
