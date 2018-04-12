//
//  Resource.swift
//  RestStop
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
    
    public func getList() -> Single<Result<T>> {
        return self.adapter.getList(resourceName: name, pagination: nil, filters: nil)
    }
    
    public func getOne(id: String) -> Single<T?> {
        return self.adapter.getOne(resourceName: name, id: id)
    }
}
