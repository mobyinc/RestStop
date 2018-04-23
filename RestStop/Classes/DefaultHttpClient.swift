//
//  DefaultJsonClient.swift
//  RestStop
//  A defaut implementation of HTTPClientProtocol using the shared URLSession
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

open class DefaultHttpClient : HttpClientProtocol {
    public init() { }

    public func send(request: URLRequest) -> Observable<Data> {
        return Observable<Data>.create { observer in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                if let data = data {
                    observer.onNext(data)
                    observer.onCompleted()
                } else {
                    observer.onError(RestError.noData)
                }
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}


