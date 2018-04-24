//
//  Result.swift
//  RestStop
//  The metadata and item results from a list request.
//
//  Created by James Jacoby on 4/2/18.
//

import Foundation
import RxSwift

public struct ListResult<T: Codable & Identifiable> {
    public var total: Int
    public var page: Int
    public var perPage: Int
    public var items: Array<T>
    
    public init(total: Int, page: Int, perPage: Int, items: Array<T>) {
        self.total = total
        self.page = page
        self.perPage = perPage
        self.items = items
    }
    
    public func first() -> T? {
        return self.items.first
    }
}
