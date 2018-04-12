//
//  DefaultRestAdapter.swift
//  RestStop
//
//  Created by James Jacoby on 4/2/18.
//

import Foundation
import RxSwift

public struct GetResponse<T: Codable>: Codable {
    public var total_results: Int
    public var page: Int
    public var per_page: Int
    public var results: Array<T>
}

open class DefaultRestAdapter : RestAdaptable {
    public private(set) var baseUrl: URL
    public private(set) var client: HttpClientProtocol
    
    public init(baseUrlString: String, httpClient: HttpClientProtocol) {
        self.baseUrl = URL(string: baseUrlString)!
        self.client = httpClient
    }

    open func getList<T: Codable>(resourceName: String, pagination: Pagination?, filters: Filter?) -> Single<Result<T>> {
        let url = self.urlForResource(resourceName: resourceName)
        return self.client.get(url: url!).map(decodeList).asSingle()
    }
    
    open func getOne<T: Codable>(resourceName: String, id: String) -> Single<T?> {
        let url = self.urlForResource(resourceName: resourceName, id: id, action: nil)
        return self.client.get(url: url!).map(decodeOne).asSingle()
    }
    
    open func decodeList<T: Codable>(data: Data) -> Result<T> {
        do {
            let response = try JSONDecoder().decode(GetResponse<T>.self, from: data)
            return Result<T>(total: response.total_results, page: response.page, perPage: response.per_page, items: response.results)
        } catch {
            return Result<T>(total: 0, page: 0, perPage: 0, items: [])
        }
    }
    
    open func decodeOne<T: Codable>(data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    open func urlForResource(resourceName: String) -> URL? {
        return self.urlForResource(resourceName: resourceName, id: nil, action: nil)
    }
    
    open func urlForResource(resourceName: String, id: String?, action: String?) -> URL? {
        return URL(string: self.pathForResource(resourceName: resourceName, id: id, action: action), relativeTo: self.baseUrl)
    }
    
    open func pathForResource(resourceName: String, id: String?, action: String?) -> String {
        var path: String = ""
        
        if let action = action, let id = id {
            path = "\(resourceName)/\(id)/\(action)"
        } else if let id = id {
            path = "\(resourceName)/\(id)"
        } else {
            path = "\(resourceName)"
        }
        
        return path
    }
}
