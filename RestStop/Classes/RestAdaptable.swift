//
//  RestAdaptable.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

enum SortDirection: String {
    case ascending = "asc"
    case decending = "desc"
}

enum RestError: Error {
    case cantParseJSON
}

struct Pagination {
    public var page: Int
    public var perPage: Int
    public var sortField: String
    public var sortDirection: SortDirection
}

struct Filter {
    public var field: String
    public var value: String
    public var op: String
}

protocol RestAdaptable {
    func getList(resourceName: String, pagination: Pagination?, filters: Filter?) -> Observable<Array<Any>?>
    func getOne(resourceName: String, id: String) -> Observable<Any?>
}
