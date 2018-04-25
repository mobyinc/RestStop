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

    public func send(request: URLRequest) -> Observable<HttpResponse> {
        return Observable<HttpResponse>.create { observer in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let status = (response as! HTTPURLResponse).statusCode
                var resp = HttpResponse(code: status, data: data, error: nil)
                
                if error != nil {
                    resp.error = HttpError.connectionFailed
                    resp.internalError = error
                } else if data == nil {
                    resp.error = HttpError.noData
                } else if status < 200 || status >= 300  {
                    switch status {
                    case 400:
                        resp.error = HttpError.badRequest
                    case 401:
                        resp.error = HttpError.unauthorized
                    default:
                        resp.error = HttpError.unknown
                    }
                }
                
                observer.onNext(resp)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}


