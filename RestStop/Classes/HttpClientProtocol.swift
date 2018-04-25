//
//  HttpClientProtocol.swift
//  RestStop
//  The observable interface used to make HTTP requests
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

public struct HttpResponse {
    public var code: Int
    public var data: Data?
    public var error: HttpError?
    public var internalError: Error?
    
    public var success: Bool {
        return code >= 200 && code < 300 && error == nil && internalError == nil && data != nil
    }
    
    public init(code: Int, data: Data?, error: HttpError?) {
        self.code = code
        self.data = data
        self.error = error
    }
}

public enum HttpError: Error {
    case connectionFailed
    case noData
    case unauthorized
    case badRequest
    case unknown
}

public protocol HttpClientProtocol {
    func send(request: URLRequest) -> Observable<HttpResponse>
}
