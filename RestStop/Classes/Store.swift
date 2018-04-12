//
//  Store.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

public class Store {
    static var sharedInstance: Store?

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
    
    public func startSession(username: String, password: String, clientId: String, clientSecret: String) -> Single<Bool> {
        return self.adapter.authenticate(username: username, password: password)
            .map { response in
                guard let response = response else {
                    return false
                }
                
                UserDefaults.standard.set(response, forKey: "SESSION")
                
                self.adapter.setToken(token: response.access_token)
                
                return true
            }
    }
    
    public func restoreSession() -> Bool {
        if let session = UserDefaults.standard.object(forKey: "SESSION") as? AuthResponse {
            self.adapter.setToken(token: session.access_token)
            return true
        } else {
            return false
        }
    }
    
    public func refreshSession() {
        // TODO
    }
    
    public func endSession() {
        UserDefaults.standard.removeObject(forKey: "SESSION")
    }
    
    public func resource<T: Codable>(name: String, type: T.Type) -> Resource<T> {
        return Resource<T>(adapter: self.adapter, name: name);
    }
}
