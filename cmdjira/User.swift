//
//  User.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 13/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation
private let key = "cmdjira.users"

struct User {
    let name: String?
    let username: String
    let password: String
    let baseURL: String

    var json: JSON {
        return [
            "username": username,
            "password": password,
            "baseURL": baseURL,
            "name": name ?? ""
        ]
    }

    init(username: String, password: String, baseURL: String, name: String? = nil) {
        self.username = username
        self.password = password
        self.baseURL = baseURL
        self.name = name
    }

    init(json: JSON) {
        username = json["username"].stringValue
        password = json["password"].stringValue
        baseURL = json["baseURL"].stringValue
        name = json["name"].stringValue.isEmpty ? nil : json["name"].stringValue
    }
}

struct Users {
    var users: [User]
    var currentUsername: String?
    var current: User? {
        return users.first { $0.username == currentUsername }
    }

    mutating func update(user: User) {
        if let index = users.index(where: { $0.username == user.username}) {
            users[index] = user
        } else {
            users.append(user)
        }
    }

    @discardableResult mutating func remove(forUsername username: String) -> Bool {
        if let index = users.index(where: { $0.username == username}) {
            users.remove(at: index)
            return true
        }
        return false
    }

    @discardableResult mutating func select(username: String) -> Bool {
        if let _ = users.index(where: { $0.username == username}) {
            currentUsername = username
            return true
        }
        return false
    }

    func saveToKeychain() throws {
        let json: JSON = [
            "current": currentUsername ?? "",
            "users" : users.map {$0.json}
        ]
        let data = try json.rawData()
        KeychainSwift().set(data, forKey: key)
    }

    init() {
        guard let data = KeychainSwift().getData(key) else {
            currentUsername = nil
            users = []
            return
        }

        let json = JSON(data)
        currentUsername = json["current"].stringValue.isEmpty ? nil : json["current"].stringValue
        users = json["users"].arrayValue.map {User(json: $0)}
    }
}
