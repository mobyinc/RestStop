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
    private final var AUTH_CACHE_KEY = "authcachekey"
    static var sharedInstance: Store?

    public static var shared: Store! {
        return Store.sharedInstance!
    }
    
    public private(set) var adapter: RestAdaptable
    private var cache: LocalCacheProtocol;

    public init(adapter: RestAdaptable, cache: LocalCacheProtocol) {
        self.adapter = adapter;
        self.cache = cache;
        
        if Store.sharedInstance == nil {
            Store.sharedInstance = self
        }
    }
    
    // MARK: Session
    
    public func startSession(path: String, username: String, password: String) -> Single<Bool> {
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
    
    public func restoreSession() -> Bool {
        if let value = self.cache.get(self.AUTH_CACHE_KEY),
            let auth = value.asType(Authentication.self) {
            self.adapter.setAuthentication(auth: auth)
            return true
        } else {
            return false
        }
    }
    
    public func refreshSession() -> Bool {
        // TODO
        return false;
    }
    
    public func endSession() {
        self.cache.delete(AUTH_CACHE_KEY)
    }
    
    // MARK: Data Access
    
    public func get(path: String) -> Single<Resource> {
        return self.get(path: path, parameters: nil)
    }
    
    public func get(path: String, parameters: [String:String]?) -> Single<Resource> {
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
    
    public func post<T: Codable>(path: String, parameters: [String:String]?, object: T) -> Single<Resource> {
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

    // MARK: Utility
    
    private func cacheKeyForRequest(path: String, parameters: [String:String]?, data: Data?) -> String {
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
    
    private func md5(data: Data) -> String {
        return MD5(String(describing: data))
    }
}
