//
//  CacheProtocol.swift
//  Pagliacci-Core
//
//  Created by James Jacoby on 5/4/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

public protocol LocalCacheProtocol {
    func set(key: String, value: Resource)
    func set(key: String, value: Resource, expiresAt: Date?)
    func get(_ key: String) -> Resource?
    func delete(_ key: String)
}
