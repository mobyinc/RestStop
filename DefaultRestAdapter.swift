//
//  DefaultRestAdapter.swift
//  RestStop
//
//  Created by James Jacoby on 4/2/18.
//

import Foundation
import RxSwift

open class DefaultRestAdapter : RestAdaptable {
    var baseUrl: URL;
    var client: HttpClientProtocol;
    
    public init(baseUrlString: String, httpClient: HttpClientProtocol) {
        self.baseUrl = URL(string: baseUrlString)!
        self.client = httpClient
    }

    public func getList(resourceName: String, pagination: Pagination?, filters: Filter?) -> Observable<Result> {
        let url = self.urlForResource(resourceName: resourceName)
        return self.client.get(url: url!).map({ (obj: Any) -> Result in
            let json = obj as! [String: Any]
            return Result(total: json["total_results"] as! Int, page: json["page"] as! Int, perPage: json["per_page"] as! Int, items: json["results"] as! Array<Any>)
        })
    }
    
    public func urlForResource(resourceName: String) -> URL? {
        return self.urlForResource(resourceName: resourceName, id: nil, action: nil)
    }
    
    public func urlForResource(resourceName: String, id: String?, action: String?) -> URL? {
        return URL(string: self.pathForResource(resourceName: resourceName, id: id, action: action), relativeTo: self.baseUrl)
    }
    
    public func pathForResource(resourceName: String, id: String?, action: String?) -> String {
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
