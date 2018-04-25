//
//  RestAdaptable.swift
//  RestStop
//  The standard interface for REST API iteractions, which all project APIs are adapted to.
//  Suggested to start by sub-classing DefaultRestAdapter
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

public struct GetListResponse<T: Codable>: Codable {
    public var total_results: Int
    public var page: Int
    public var per_page: Int
    public var results: Array<T>
}

public struct AuthResponse: Codable {
    
    public init(access_token: String, token_type: String, expires_in: String, refresh_token: String, scope: String) {
        self.access_token = access_token
        self.token_type = token_type
        self.expires_in = expires_in
        self.refresh_token = refresh_token
        self.scope = scope
    }
    
    public var access_token: String
    public var token_type: String
    public var expires_in: String
    public var refresh_token: String
    public var scope: String
}

public struct ErrorResponse: Codable {
    public var code: Int
    public var message: String
    public var errors: [String]
    
    public init(code: Int, message: String, errors: [String]) {
        self.code = code
        self.message = message
        self.errors = errors
    }
}

public enum RestError: Error {
    case protocolFailure
    case unauthorized(ErrorResponse?)
    case badRequest(ErrorResponse?)
    case unknown(ErrorResponse?)
}

public protocol RestAdaptable {
    func authenticate(username: String, password: String) -> Single<AuthResponse?>
    func setAuthorization(auth: AuthResponse)
    func getList<T: Codable & Identifiable>(resourceName: String, pagination: Pagination?, filters: Filter?) -> Single<ListResult<T>>
    func getOne<T: Codable & Identifiable>(resourceName: String, id: String) -> Single<T?>
    func save<T: Codable & Identifiable>(resourceName: String, item: T) -> Single<T?>
    func post<T: Codable, J: Codable>(resourceName: String, item: T, type: J.Type) -> Single<J?>
    func remove(resourceName: String, id: String) -> Single<Bool>
}
