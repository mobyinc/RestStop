//
//  INatRestAdapter.swift
//  RestStop_Example
//
//  Created by James Jacoby on 4/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import RestStop
import RxSwift

public class INatRestAdapater : DefaultRestAdapter {
    override open func decodeOne<T: Codable>(data: Data) -> T? {
        do {
            let response: GetResponse<T> = try JSONDecoder().decode(GetResponse<T>.self, from: data)
            return response.results.first
        } catch {
            return nil
        }
    }
}
