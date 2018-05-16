//
//  Store.swift
//  RestStop
//  The base object used to retrieve resources and manipulate a user session
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift
import SwiftHash

public class Store {
    public private(set) static var adapter: RestAdaptable!
    
    private static var AUTH_CACHE_KEY = "authcachekey"   
    private static var cache: LocalCacheProtocol!
    
    public init(adapter: RestAdaptable, cache: LocalCacheProtocol) {
        Store.adapter = adapter
        Store.cache = cache
    }
    
    // MARK: Session
    
    public static func startSession(path: String, username: String, password: String) -> Single<Bool> {
        return self.adapter.authenticate(path: path, username: username, password: password)
            .map { auth in
                guard let auth = auth else {
                    return false
                }
                
                self.cache.set(key: self.AUTH_CACHE_KEY, value: auth.toResource())
                self.adapter.setAuthentication(auth: auth)
                
                return true
        }
    }
    
    public static func restoreSession() -> Bool {
        if let value = self.cache.get(self.AUTH_CACHE_KEY),
            let auth = value.asType(Authentication.self) {
            self.adapter.setAuthentication(auth: auth)
            return true
        } else {
            return false
        }
    }
    
    public static func refreshSession() -> Bool {
        // TODO
        return false
    }
    
    public static func endSession(_ path: String) -> Single<Bool> {
        cache.delete(AUTH_CACHE_KEY)
        
        return post(path: path)
    }
    
    // MARK: Data Access
    
    public static func get(path: String) -> Single<Resource> {
        return self.get(path: path, parameters: nil)
    }
    
    public static func get(path: String, parameters: [String:String]?) -> Single<Resource> {
        let key = self.cacheKeyForRequest(path: path, parameters: parameters, data: nil)
        let value = self.cache.get(key)
        
        if let resource = value {
            return Single.just(resource)
        } else {
            return self.adapter.get(path: path, parameters: parameters)
                .map { resource in
                    self.cache.set(key: key, value: resource)
                    return resource
            }
        }
    }
    
    public static func post<T: Codable>(path: String, parameters: [String:String]?, object: T) -> Single<Resource> {
        let requestBody = Resource.fromCodable(object).data
        let key = self.cacheKeyForRequest(path: path, parameters: parameters, data: requestBody)
        let value = self.cache.get(key)
        
        if let resource = value {
            return Single.just(resource)
        } else {
            return self.adapter.post(path: path, parameters: parameters, data: requestBody)
                .map { resource in
                    self.cache.set(key: key, value: resource)
                    return resource
            }
        }
    }
    
    public static func post(path: String) -> Single<Bool> {
        return adapter.post(path: path, parameters: nil, data: nil)
            .map { resource in
                return true
        }
    }
}


// MARK: Utility

private extension Store {
    
    private static func cacheKeyForRequest(path: String, parameters: [String:String]?, data: Data?) -> String {
        var keyData = path.data(using: .utf8)!
        
        if let parameters = parameters,
            let parameterData = try? JSONEncoder().encode(parameters) {
            keyData.append(parameterData)
        }
        
        if let data = data {
            keyData.append(data)
        }
        
        return self.md5(data: keyData)
    }
    
    private static func md5(data: Data) -> String {
        return MD5(String(describing: data))
    }
    
}
