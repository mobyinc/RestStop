//
//  Resource.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

class Resource {
    var name: String
    var adapter: RestAdaptable
    
    init(adapter: RestAdaptable, name: String) {
        self.adapter = adapter
        self.name = name
    }
    
    public func getOne(id: String) -> Observable<Any?> {
        return self.adapter.getOne(resourceName: self.name, id: id)
    }
}
