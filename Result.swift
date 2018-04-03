//
//  Result.swift
//  RestStop
//
//  Created by James Jacoby on 4/2/18.
//

import Foundation
import RxSwift

public struct Result {
    public var total: Int
    public var page: Int
    public var perPage: Int
    public var items: Array<Any>
    
    public init(total: Int, page: Int, perPage: Int, items: Array<Any>) {
        self.total = total
        self.page = page
        self.perPage = perPage
        self.items = items
    }
}
