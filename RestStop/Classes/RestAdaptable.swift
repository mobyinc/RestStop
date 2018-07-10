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

public typealias urlParams = [String: String]

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

public enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

public enum RestError: Error {
    case protocolFailure
    case parseError
    case unauthorized(ErrorResponse?)
    case badRequest(ErrorResponse?)
    case unknown(ErrorResponse?)
    
    public func errorResponse() -> ErrorResponse? {
        switch self {
        case .unauthorized(let response), .badRequest(let response), .unknown(let response):
            return response
        default:
            return nil
        }
    }
}

public struct Authentication: Codable {
    public var token: String
    public var parameters: [String:String]
    
    public init(token: String, parameters: [String:String]) {
        self.token = token
        self.parameters = parameters
    }
    
    public func toResource() -> Resource {
        return Resource.fromCodable(self)
    }
}

public protocol RestAdaptable {
    func authenticate(path: String, username: String, password: String) -> Single<Authentication?>
    func authenticate(path: String, username: String, magicToken: String) -> Single<Authentication?>
    func setAuthentication(auth: Authentication)
    func get(path: String, parameters: urlParams?) -> Single<Resource>
    func post(path: String, parameters: urlParams?, data: Data?) -> Single<Resource>
    func put(path: String, parameters: urlParams?, data: Data?) -> Single<Resource>
    func delete(path: String, parameters: urlParams?, data: Data?) -> Single<Resource>
    func performRequest(method: HttpMethod, path: String, parameters: urlParams?, data: Data?) -> Single<Data?>
}
