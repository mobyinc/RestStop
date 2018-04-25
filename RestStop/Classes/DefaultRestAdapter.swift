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
    public var token: String?
    
    public init(baseUrlString: String, httpClient: HttpClientProtocol) {
        self.baseUrl = URL(string: baseUrlString)!
        self.client = httpClient
    }

    open func authenticate(username: String, password: String) -> Single<AuthResponse?> {
        guard let url = self.urlForAuthentication() else {
            return Observable.of(nil).asSingle();
        }
        
        let payload = self.encodeAuthentication(username: username, password: password)
        
        guard let request = self.postRequestForUrl(url: url, parameters: payload) else {
            return Observable.of(nil).asSingle();
        }
        
        return self.client.send(request: request)
            .map(interpretResponse)
            .map(decodeAuthentication)
            .asSingle();
    }

    open func getList<T: Codable>(resourceName: String, pagination: Pagination?, filters: Filter?) -> Single<ListResult<T>> {
        let url = self.urlForResource(resourceName: resourceName)
        let request = self.requestForUrl(url: url!)
        return self.client.send(request: request)
            .map(interpretResponse)
            .map(decodeList).asSingle()
    }
    
    open func getOne<T: Codable>(resourceName: String, id: String) -> Single<T?> {
        let url = self.urlForResource(resourceName: resourceName, id: id, action: nil)
        let request = self.requestForUrl(url: url!)
        return self.client.send(request: request)
            .map(interpretResponse)
            .map(decodeOne)
            .asSingle()
    }
    
    open func save<T: Codable & Identifiable>(resourceName: String, item: T) -> Single<T?> {
        if let id = item.id {
            let url = self.urlForResource(resourceName: resourceName, id: id, action: nil)
            let request = self.requestForUrl(url: url!, method: "PUT")
            return self.client.send(request: request)
                .map(interpretResponse)
                .map(decodeOne)
                .asSingle()
        } else {
            let url = self.urlForResource(resourceName: resourceName, id: nil, action: nil)
            let request = self.requestForUrl(url: url!, method: "POST")
            return self.client.send(request: request)
                .map(interpretResponse)
                .map(decodeOne)
                .asSingle()
        }
    }
    
    open func post<T: Codable, J: Codable>(resourceName: String, item: T, type: J.Type) -> Single<J?> {
        let url = self.urlForResource(resourceName: resourceName)
        var request = self.requestForUrl(url: url!, method: "POST")
        request.httpBody = try? JSONEncoder().encode(item)
        return self.client.send(request: request).map(interpretResponse).map { data in
            do {
                return try JSONDecoder().decode(J.self, from: data)
            } catch {
                return nil
            }
        }
        .asSingle()
    }
    
    open func remove(resourceName: String, id: String) -> Single<Bool> {
        let url = self.urlForResource(resourceName: resourceName, id: id, action: nil)
        let request = self.requestForUrl(url: url!, method: "DELETE")
        return self.client.send(request: request).map(interpretResponse).map(decodeRemove).asSingle()
    }
    
    open func encodeAuthentication(username: String, password: String) -> Dictionary<String, Any> {
        return [
            "username": username,
            "password": password,
            "grant_type": "password",
            "client_id": "test",
            "client_secret": "test"
        ]
    }
    
    open func decodeAuthentication(data: Data) -> AuthResponse? {
        return try? JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    open func decodeList<T: Codable>(data: Data) -> ListResult<T> {
        do {
            let response = try JSONDecoder().decode(GetListResponse<T>.self, from: data)
            return ListResult<T>(total: response.total_results, page: response.page, perPage: response.per_page, items: response.results)
        } catch {
            return ListResult<T>(total: 0, page: 0, perPage: 0, items: [])
        }
    }
    
    open func decodeOne<T: Codable>(data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    open func decodeRemove(data: Data) -> Bool {
        return true // non-error response is succcess
    }
    
    open func decodeError(data: Data) -> ErrorResponse? {
        do {
            return try JSONDecoder().decode(ErrorResponse.self, from: data)
        } catch {
            return nil
        }
    }
    
    open func urlForAuthentication() -> URL? {
        return URL(string: "oauth/authorize", relativeTo: self.baseUrl)
    }
    
    open func urlForResource(resourceName: String) -> URL? {
        return self.urlForResource(resourceName: resourceName, id: nil, action: nil)
    }
    
    open func urlForResource(resourceName: String, id: String?, action: String?) -> URL? {
        return URL(string: self.pathForResource(resourceName: resourceName, id: id, action: action), relativeTo: self.baseUrl)
    }
    
    open func pathForResource(resourceName: String, id: String?, action: String?) -> String {
        var path: String = ""
        
        if let action = action, let id = id {
            path = "\(resourceName)/\(id)/\(action)"
        } else if let id = id {
            path = "\(resourceName)/\(id)"
        } else {
            path = "\(resourceName)"
        }
        
        return path
    }
    
    open func postRequestForUrl(url: URL, parameters: Dictionary<String, Any>) -> URLRequest? {
        var request = self.requestForUrl(url: url, method: "POST")
        
        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            request.httpBody = json
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        } catch {
            return nil
        }
        
        return request
    }
    
    open func requestForUrl(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        self.authorizeRequest(request: &request)
        return request
    }
    
    open func setAuthorization(auth: AuthResponse) {
        self.token = auth.access_token
    }

    open func authorizeRequest(request: inout URLRequest) {
        if let token = self.token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
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
