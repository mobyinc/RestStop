//
//  DefaultRestAdapter.swift
//  RestStop
//  A default implementation of RestAdaptable to be used as a starting point for project adapters.
//  It is unlikley that any real API maps to this adapater out of the box.
//
//  Created by James Jacoby on 4/2/18.
//

import Foundation
import RxSwift

open class DefaultRestAdapter : RestAdaptable {
    public private(set) var baseUrl: URL
    public private(set) var client: HttpClientProtocol
    
    public var authentication: Authentication?
    
    public init(baseUrlString: String, httpClient: HttpClientProtocol) {
        self.baseUrl = URL(string: baseUrlString)!
        self.client = httpClient
    }

    // MARK: Authentication
    
    open func authenticate(path: String, username: String, password: String) -> Single<Authentication?> {
        let data = self.encodeAuthentication(username: username, password: password)

        return self.performRequest(method: .POST, path: path, parameters: nil, data: data)
            .map { self.decodeAuthentication(data: $0) }
    }
    
    open func setAuthentication(auth: Authentication) {
        self.authentication = auth
    }
    
    open func encodeAuthentication(username: String, password: String) -> Data? {
        let parameters = [
            "username": username,
            "password": password,
            "grant_type": "password"
        ]
        
        return try? JSONEncoder().encode(parameters)
    }
    
    open func decodeAuthentication(data: Data?) -> Authentication? {
        return nil // must override
    }
    
    open func authorizeRequest(request: inout URLRequest) {
        if let auth = self.authentication {
            request.addValue("Bearer \(auth.token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    // MARK: Request Methods

    open func get(path: String, parameters: [String:String]?) -> Single<Resource> {
        return self.performRequest(method: .GET, path: path, parameters: parameters, data: nil)
            .map { Resource(data: $0) }
    }

    open func post(path: String, parameters: [String:String]?, data: Data?) -> Single<Resource> {
        return self.performRequest(method: .POST, path: path, parameters: parameters, data: data)
            .map { Resource(data: $0) }
    }
    
    open func performRequest(method: HttpMethod, path: String, parameters: [String:String]?, data: Data?) -> Single<Data?> {
        guard let url = self.urlWithPath(path, parameters: parameters) else {
            return Single.just(nil)
        }
        
        var request = self.requestWithUrl(url, method: method.rawValue)
        request.httpBody = data
        
        return self.client.send(request: request)
            .map(interpretResponse)
    }

    // MARK: Request Preparation
    
    open func urlWithPath(_ path: String, parameters: [String:String]? = nil) -> URL? {
        guard let url = URL(string: path, relativeTo: self.baseUrl) else {
            return nil
        }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        if let params = parameters {
            components.queryItems = params.keys.map { key in
                return URLQueryItem(name: key, value: params[key])
            }
        }
        
        return components.url
    }
    
    open func requestWithUrl(_ url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if method == "POST" || method == "PUT" {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        self.authorizeRequest(request: &request)
        
        return request
    }
    
    // MARK: Error Handling
    
    open func decodeError(data: Data, request: URLRequest?) -> ErrorResponse? {
        return try? JSONDecoder().decode(ErrorResponse.self, from: data)
    }
    
    open func interpretResponse(response: HttpResponse) throws -> Data {
        if response.success {
            return response.data!
        } else if response.data != nil {
            if let error = response.error,
               let errorResponse = self.decodeError(data: response.data!, request: response.originalRequest) {
               
                switch error {
                case .badRequest:
                    throw RestError.badRequest(errorResponse)
                case .unauthorized:
                    throw RestError.unauthorized(errorResponse)
                default:
                    throw RestError.unknown(errorResponse)
                }
            } else {
                throw RestError.protocolFailure
            }
        } else {
            throw RestError.protocolFailure
        }
    }
}
