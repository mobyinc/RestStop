//
//  Resource.swift
//  RestStop
//  A representation of a REST resource which may be used make requests
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

public class Resource<T: Codable> {
    var name: String
    var adapter: RestAdaptable
    
    init(adapter: RestAdaptable, name: String) {
        self.adapter = adapter
        self.name = name
    }
    
    public func task(name: String) -> Resource<T> {
        return Resource<T>(adapter: self.adapter, name: "\(self.name)/\(name)")
    }
    
    public func getList() -> Single<ListResult<T>> {
        return self.getList(pagination: nil, filters: nil)
    }
    
    public func getList(pagination: Pagination?) -> Single<ListResult<T>> {
        return self.getList(pagination: pagination, filters: nil)
    }
    
    public func getList(pagination: Pagination?, filters: Filter?) -> Single<ListResult<T>> {
        return self.adapter.getList(resourceName: name, pagination: nil, filters: nil)
    }
    
    public func getOne(id: String) -> Single<T?> {
        return self.adapter.getOne(resourceName: name, id: id)
    }
    
    public func remove(id: String) ->Single<Bool> {
        return self.adapter.remove(resourceName: name, id: id)
    }
}
