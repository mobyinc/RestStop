//
//  HttpClientProtocol.swift
//  RestStop
//
//  Created by James Jacoby on 4/1/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation
import RxSwift

public protocol HttpClientProtocol {
    func get(url: URL) -> Observable<Any>
}
