//
//  Store.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

class Store {
    var adapter: RestAdaptable
    
    init(adapter: RestAdaptable) {
        self.adapter = adapter;
    }
    
    public func resource(name: String) -> Resource {
        return Resource(adapter: self.adapter, name: name);
    }
}