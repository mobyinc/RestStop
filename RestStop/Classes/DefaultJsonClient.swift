//
//  DefaultJsonClient.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

class DefaultJsonClient : HttpClientProtocol {
    public func get(url: String) -> Single<Any?> {
        return Single<Any?>.create { single in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                        single(.error(RestError.cantParseJSON))
                        return
                }
                
                single(.success(json))
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}
