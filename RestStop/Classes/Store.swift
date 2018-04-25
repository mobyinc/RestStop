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

public class Store {
    static var sharedInstance: Store?
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    public static var shared: Store! {
        return Store.sharedInstance!
    }
    
    var adapter: RestAdaptable

    public init(adapter: RestAdaptable) {
        self.adapter = adapter;
        
        if Store.sharedInstance == nil {
            Store.sharedInstance = self
        }
    }
    
    public func startSession(username: String, password: String) -> Single<Bool> {
        return self.adapter.authenticate(username: username, password: password)
            .map { response in
                guard let response = response else {
                    return false
                }
                
                if let encoded = try? self.encoder.encode(response) {
                    UserDefaults.standard.set(encoded, forKey: "SESSION")
                    self.adapter.setAuthorization(auth: response)
                    return true
                } else {
                    return false
                }
            }
    }
    
    public func restoreSession() -> Bool {
        if let session = UserDefaults.standard.data(forKey: "SESSION") {
            if let decoded = try? self.decoder.decode(AuthResponse.self, from: session) {
                self.adapter.setAuthorization(auth: decoded)
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public func refreshSession(withRefreshToken: Bool) {
        // TODO
    }
    
    public func endSession() {
        UserDefaults.standard.removeObject(forKey: "SESSION")
    }
    
    public func resource<T: Codable & Identifiable>(name: String, type: T.Type) -> Resource<T> {
        return Resource<T>(adapter: self.adapter, name: name);
    }
}
