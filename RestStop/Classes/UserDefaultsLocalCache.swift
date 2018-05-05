//
//  UserDefaultsCache.swift
//  RestStop
//
//  Created by James Jacoby on 5/4/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

open class UserDefaultsLocalCache : LocalCacheProtocol {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    public init() {
    
    }

    private struct Entry : Codable {
        public var expiresAt: Date?
        public var value: Resource
    }
    
    public func set(key: String, value: Resource) {
        self.set(key: key, value: value, expiresAt: nil)
    }
    
    public func set(key: String, value: Resource, expiresAt: Date?) {
        let entry = Entry(expiresAt: expiresAt, value: value)
        
        if let encoded = try? self.encoder.encode(entry) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    public func get(_ key: String) -> Resource? {
        if let encoded = UserDefaults.standard.data(forKey: key),
            let entry = try? self.decoder.decode(Entry.self, from: encoded) {
            if entry.expiresAt == nil || entry.expiresAt! > Date() {
                return entry.value
            } else {
                self.delete(key)
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func delete(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
