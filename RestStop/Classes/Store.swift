//
//  Store.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

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
    
    public func resource<T: Codable>(name: String, type: T.Type) -> Resource<T> {
        return Resource<T>(adapter: self.adapter, name: name);
    }
}
