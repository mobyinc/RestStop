//
//  RestAdaptable.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

public enum SortDirection: String {
    case ascending = "asc"
    case decending = "desc"
}

public enum RestError: Error {
    case cantParseJSON
    case noData
}

public struct Pagination {
    public var page: Int
    public var perPage: Int
    public var sortField: String
    public var sortDirection: SortDirection
}

public struct Filter {
    public var field: String
    public var value: String
    public var op: String
}

public protocol RestAdaptable {
    func authenticate(username: String, password: String) -> Single<AuthResponse?>
    func setToken(token: String)
    func getList<T: Codable>(resourceName: String, pagination: Pagination?, filters: Filter?) -> Single<Result<T>>
    func getOne<T: Codable>(resourceName: String, id: String) -> Single<T?>
}
