//
//  DefaultJsonClient.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class DefaultJsonClient : HttpClientProtocol {
    public func get(url: String) -> Observable<Any?> {
        return Observable.create { observer in
            Alamofire.request(url).response { response in
                if let error = response.error {
                    observer.onError(error)
                } else if let data = response.data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    observer.onNext(json)
                }
            }
            
            return Disposables.create()
        }
    }
}
