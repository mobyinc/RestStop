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
    public var debug: Bool = false

    public init() { }

    public func send(request: URLRequest) -> Observable<HttpResponse> {
        if self.debug { self.log(request: request) }
        
        return Observable<HttpResponse>.create { observer in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let httpResponse = (response as! HTTPURLResponse)

                if self.debug { self.log(data: data, response: httpResponse, error: error) }
                
                let status = httpResponse.statusCode
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
    
    private func log(request: URLRequest) {
        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"
        
        var requestLog = "\n---------- OUT ---------->\n"
        
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        
        if let body = request.httpBody {
            requestLog += "\n\(NSString(data: body, encoding: String.Encoding.utf8.rawValue)!)\n"
        }
        
        requestLog += "\n------------------------->\n";
        
        print(requestLog)
    }
    
    private func log(data: Data?, response: HTTPURLResponse?, error: Error?){
        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")
        
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        
        var responseLog = "\n<---------- IN ----------\n"

        if let urlString = urlString {
            responseLog += "\(urlString)"
            responseLog += "\n\n"
        }
        
        if let statusCode =  response?.statusCode {
            responseLog += "HTTP \(statusCode) \(path)?\(query)\n"
        }
        
        if let host = components?.host {
            responseLog += "Host: \(host)\n"
        }
        
        for (key,value) in response?.allHeaderFields ?? [:] {
            responseLog += "\(key): \(value)\n"
        }
        
        if let body = data {
            responseLog += "\n\(NSString(data: body, encoding: String.Encoding.utf8.rawValue)!)\n"
        }

        if error != nil {
            responseLog += "\nError: \(error!.localizedDescription)\n"
        }
        
        responseLog += "<------------------------\n";
        
        print(responseLog)
    }
}


