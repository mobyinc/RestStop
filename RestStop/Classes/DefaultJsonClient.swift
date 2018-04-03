//
//  DefaultJsonClient.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

open class DefaultJsonClient : HttpClientProtocol {
    public init() { }

    public func get(url: URL) -> Observable<Any> {
        return Observable<Any>.create { observer in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                        observer.onError(RestError.cantParseJSON)
                        return
                }
                
                observer.onNext(json)
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}


