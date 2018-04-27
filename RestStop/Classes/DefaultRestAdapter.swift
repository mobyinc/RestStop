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

        return self.performBodyRequest(method: "POST", path: path, parameters: nil, data: data)
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
    
    open func get<T: Codable>(path: String, responseType: T.Type) -> Single<T?> {
        return self.get(path: path, parameters: nil, responseType: responseType)
    }

    open func get<T: Codable>(path: String, parameters: [String:String]?, responseType: T.Type) -> Single<T?> {
        guard let url = self.urlWithPath(path, parameters: parameters) else {
            return Observable.of(nil).asSingle()
        }
        
        let request = self.requestWithUrl(url)
        
        return self.client.send(request: request)
            .map(interpretResponse)
            .map { try? JSONDecoder().decode(T.self, from: $0) }
            .asSingle()
    }
    
    open func post<T: Codable, J: Codable>(path: String, requestObject: T?, responseType: J.Type) -> Single<J?> {
        return self.post(path: path, parameters: nil, requestObject: requestObject, responseType: responseType)
    }
    
    open func post<T: Codable, J: Codable>(path: String, parameters: [String:String]?, requestObject: T?, responseType: J.Type) -> Single<J?> {
        let data = try? JSONEncoder().encode(requestObject)

        return self.post(path: path, parameters: parameters, data: data, responseType: responseType)
    }
    
    open func post<T: Codable>(path: String, parameters: [String:String]?, data: Data?, responseType: T.Type) -> Single<T?> {
        return self.performBodyRequest(method: "POST", path: path, parameters: parameters, data: data, responseType: responseType)
    }
    
    open func performBodyRequest<T: Codable>(method: String, path: String, parameters: [String:String]?, data: Data?, responseType: T.Type) -> Single<T?> {
        return self.performBodyRequest(method: method, path: path, parameters: parameters, data: data)
            .map { data in
                if let data = data {
                    return try? JSONDecoder().decode(T.self, from: data)
                } else {
                    return nil
                }
            }
    }
    
    open func performBodyRequest(method: String, path: String, parameters: [String:String]?, data: Data?) -> Single<Data?> {
        guard let url = self.urlWithPath(path, parameters: parameters) else {
            return Observable.of(nil).asSingle()
        }
        
        var request = self.requestWithUrl(url, method: method)
        request.httpBody = data
        
        return self.client.send(request: request)
            .map(interpretResponse)
            .asSingle()
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
    
    open func decodeError(data: Data) -> ErrorResponse? {
        return try? JSONDecoder().decode(ErrorResponse.self, from: data)
    }
    
    open func interpretResponse(response: HttpResponse) throws -> Data {
        if response.success {
            return response.data!
        } else if response.data != nil {
            if let error = response.error,
               let errorResponse = self.decodeError(data: response.data!) {
               
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
